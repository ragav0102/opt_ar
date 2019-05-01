module OptAR
  module MethodFinderHelper
    ID_STRING = 'id'.freeze
    WARN_MSG = 'WARNING :: Trying to access attr that was not requested'.freeze

    private

    # def attr_reader_proc
    #   proc.new {
    #     return @attributes[method_name] if @attributes.key?(method_name)
    #   }
    # end

    # Checks for attribute from the attributes hash and returns if found
    #
    # Overriding to avoid attributes misses from causing an error
    # It just throws a warning and proceeds with fetching the actual
    #   ActiveRecord object,to check for it's response to the method
    #   defined by name method_name
    #
    # Provided only as a fallback for the worst case scenario. Avoid calling
    #   methods on the instance, for attribute that was not requested initially
    def method_missing(method_name, *args)
      method_name = method_name.to_sym
      return @attributes[method_name] if @attributes.key?(method_name)

      raise OptAR::Errors::MissingPrimaryKeyError if primary_key?(method_name)

      raise OptAR::Errors::MutationNotAllowedError if assign?(method_name)

      Rails.logger.warn "#{WARN_MSG} :: #{method_name}"
      load_ar_object
      @klass_object ? @klass_object.send(method_name, *args) : super
    end

    # Introducing this as a best practice when overriding method_missing
    #
    # Be cautious of using respond_to? as this will try to query for the
    #   actual ActiveRecord object and check for it's response
    def respond_to_missing?(*args)
      load_ar_object
      @klass_object.respond_to?(*args)
    end

    # Default scope for the class defined by klass_name will be applied here
    def load_ar_object
      @klass_object ||= klass_name.constantize
                                  .where(id: id)
                                  .first(readonly: true)
      raise OptAR::Errors::ARObjectNotFoundError unless @klass_object
    end

    def klass_key
      klass_name.gsub('::', '_').underscore
    end

    def klass_primary_key(klass)
      klass.primary_key.to_sym
    end

    def primary_key?(method_name)
      method_name == klass_primary_key(klass_name.constantize)
    end

    def assign?(method_name)
      method_name.to_s.include?('=')
    end
  end
end
