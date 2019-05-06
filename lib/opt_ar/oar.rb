require File.dirname(__FILE__) + '/helpers/method_finder_helper'

module OptAR
  # Dupe of ActiveRecord::Base providing necessary read functionalities
  #   of it, while removing a lot of abstactions that it provides
  #   to reduce memory and processing time utilisation
  #
  # attributes   : contains the requested attributes from AR
  # klass_name   : class name of original AR model
  # klass_object : original AR object loaded
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

    def self.init_manual(attrs, klass, req_attributes)
      oar = allocate
      attr_keys = oar.send(:fetch_attribute_keys, req_attributes, klass)
      attrs = attrs.slice(*attr_keys)
      oar.instance_variable_set('@attributes', attrs)
      oar.instance_variable_set('@klass_name', klass.name)
      oar.send(:transform_datetime_attributes, klass)
      oar
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
      p_key = klass_primary_key(klass)

      unless obj_attributes[p_key]
        raise OptAR::Errors::MandatoryPrimaryKeyMissingError
      end

      attribute_keys = fetch_attribute_keys(req_attributes, klass)
      @attributes = obj_attributes.slice(*attribute_keys)
      transform_datetime_attributes(object.class)
    end

    def fetch_attribute_keys(req_attributes, klass)
      req_attributes + mandatory_attributes(klass) - skipped_attributes(klass)
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

    def transform_datetime_attributes(klass)
      fields = transformable_fields(klass)
      return unless fields.present?
      fields.each do |field|
        val = attributes[field]
        raise OptAR::Errors::TimeTypeExpectedError unless val.is_a?(Time)
        attributes[field] = val.to_i
      end
    ensure
      attributes.freeze
    end

    def marshal_dump
      [@attributes, @klass_name]
    end

    def marshal_load(result)
      @attributes, @klass_name = result
    end
  end
end
