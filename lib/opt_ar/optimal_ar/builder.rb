require 'active_support/core_ext/kernel/singleton_class'
require File.dirname(__FILE__) + '/../optimal_active_record'

module OptAR
  module OptimalAR
    module Builder
      module ClassMethods
        def build_opt_ar(name, options = {})
          validate_name(name)
          faker_proc = lambda do |*args|
            options = options.respond_to?(:call) ? unscoped { options.call(*args) } : options
            scope = options[:scope]
            if scope
              valid_scope?(scope) ? safe_send(scope).opt_ar_objects(options) : throw_error(:undefined_scope, scope: scope)
            else
              safe_send(:build_default_scope).opt_ar_objects(options)
            end
          end
          singleton_class.safe_send(:redefine_method, name, &faker_proc)
        end

        alias show_as build_opt_ar

        private

          def valid_scope?(scope_name)
            respond_to? scope_name
          end

          def validate_name(name)
            valid = valid_name?(name)
            throw_error(:invalid_name, name: name, type: valid) unless valid == true
          end

          def valid_name?(name)
            if !name.is_a?(Symbol)
              :symbol_expected
            elsif respond_to? name
              :duplicate_name
            else
              true
            end
          end

          def throw_error(error_type, error_options)
            raise safe_send(error_type, error_options)
          end

          def undefined_scope(options)
            Rails.logger.error(" :: show_as defined with Undefined Scope :: #{options[:scope]}")
            OptAR::Error::UndefinedScopeError.new(options)
          end

          def invalid_name(options)
            Rails.logger.error(" :: show_as defined with invalid name :: #{options[:name]} :: #{options[:type]}")
            OptAR::Error::DuplicateNameError.new(options)
          end
      end

      module InstanceMethods
        def opt_ar_object(options = {})
          OptAR::OptimalActiveRecord.new(self, options)
        end

        alias opt_ar_objects opt_ar_object
      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end
