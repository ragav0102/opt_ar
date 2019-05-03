require File.dirname(__FILE__) + '/helpers/method_finder_helper'

module OptAR
  class OAR
    include OptAR::MethodFinderHelper

    attr_reader :attributes, :klass_name, :klass_object

    BLACKLISTED_ATTRIBUTES = 'BLACKLISTED_ATTRIBUTES'.freeze

    def initialize(object, options = {})
      req_attributes = options[:req_attributes] || []
      assign_attributes(object, req_attributes)
      @klass_name = object.class.name
      # define_attr_readers
    end

    def as_json
      {
        klass_key => attributes.as_json
      }
    end

    def to_json
      JSON.dump(as_json)
    end

    # TODO: for handling JSON serialization
    def self.from_json(string); end

    private

    # def define_attr_readers
    #   @attributes.each_pair do |attri, val|
    #     define_singleton_method attri do
    #       val
    #     end
    #   end
    # end

    # By default only the primary key will be fetched
    # Any required attribute has to be called out deliberately
    def assign_attributes(object, req_attributes)
      obj_attributes = object.attributes.symbolize_keys
      klass = object.class
      attribute_keys = req_attributes +
                       mandatory_attributes(klass) -
                       skipped_attributes(klass)
      @attributes = obj_attributes.slice(*attribute_keys).freeze
    end

    def mandatory_attributes(klass)
      [klass_primary_key(klass)]
    end

    # Skips fetching attributes defined by BLACKLISTED_ATTRIBUTES constant
    #   for the ActiveRecord class
    # Can be used to prevent exposing attributes having PII, password,
    #   security related information to the outside world
    def skipped_attributes(klass)
      if klass.const_defined?(BLACKLISTED_ATTRIBUTES)
        attrs = klass.const_get(BLACKLISTED_ATTRIBUTES)
        if attrs.include? klass_primary_key(klass)
          raise OptAR::Errors::PrimaryKeyBlacklistedError
        end
        attrs
      else
        []
      end
    end

    def marshal_dump
      [@attributes, @klass_name]
    end

    def marshal_load(result)
      @attributes, @klass_name = result
    end
  end
end
