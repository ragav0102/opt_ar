require 'active_support/core_ext/kernel/singleton_class'
require File.dirname(__FILE__) + '/../oar'

module OptAR
  module OptimalAR
    module Builder
      module ClassMethods
        def build_optar(name, options = {})
          validate_name(name)
          validate_scope(options[:scope]) if options[:scope]
          faker_proc = lambda do |*args|
            fetch_optar_objects(options[:scope], options)
          end
          singleton_class.send(:redefine_method, name, &faker_proc)
        end

        alias swindle build_optar
        alias show_as build_optar

        private

        def validate_scope(scope_name)
          valid = valid_scope?(scope_name)
          return if valid == true
          throw_error(:undefined_scope, scope: scope_name)
        end

        def valid_scope?(scope_name)
          respond_to? scope_name
        end

        def validate_name(name)
          valid = valid_name?(name)
          return true if valid == true
          throw_error(:invalid_name, name: name, type: valid)
        end

        def valid_name?(name)
          if respond_to? name
            :duplicate_name
          else
            true
          end
        end

        def fetch_optar_objects(scope, options)
          if scope
            fetch_scoped_optar(scope, options)
          else
            fetch_default_scoped_optars(options)
          end
        end

        def fetch_scoped_optar(scope, options)
          send(scope).optars(options)
        end

        def fetch_default_scoped_optars(options)
          send(:build_default_scope).optars(options)
        end

        def throw_error(error_type, error_options)
          raise send(error_type, error_options)
        end

        def undefined_scope(options)
          msg = " :: swindle defined with Undefined Scope :: #{options[:scope]}"
          OptAR::Logger.log(msg, :error)
          OptAR::Errors::UndefinedScopeError.new(options)
        end

        def invalid_name(options)
          error_options = "#{options[:name]} :: #{options[:type]}"
          msg = " :: swindle defined with invalid name :: #{error_options}"
          OptAR::Logger.log(msg, :error)
          OptAR::Errors::DuplicateNameError.new(options)
        end
      end

      module InstanceMethods
        def optar(options = {})
          OptAR::OAR.new(self, options)
        end

        alias optars optar
        alias opt_ar_objects optar
        alias opt_ar_object optar
      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end
