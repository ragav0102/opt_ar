$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'coveralls'
Coveralls.wear!

require 'simplecov'
require 'simplecov-console'

require 'opt_ar'

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/stub_const'
require 'minitest/ci'
# SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter([
#   SimpleCov::Formatter::ShieldFormatter,
#   SimpleCov::Formatter::HTMLFormatter
# ])

# SimpleCov::Formatter::ShieldFormatter.config[:option] = value

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::Console,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  # add_filter '/lib/'
  add_filter 'test'
end

Minitest::Ci.report_dir = 'tmp/test-results'

require_relative 'models/test_models'
require_relative './setup/mysql'

WARN_MSG = 'WARNING :: Trying to access attr that was not requested'.freeze
EMPLOYEE = 'Employee'.freeze

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]
# Minitest::Reporters::ProgressReporter.new]
