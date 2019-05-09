$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start do
  add_filter %r{^/test/}
end

require 'opt_ar'

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/stub_const'
require 'minitest/ci'

Minitest::Ci.report_dir = 'tmp/test-results'

require_relative 'models/test_models'
require_relative './setup/mysql'

WARN_MSG = 'WARNING :: Trying to access attr that was not requested'.freeze
EMPLOYEE = 'Employee'.freeze

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]
# Minitest::Reporters::ProgressReporter.new]
