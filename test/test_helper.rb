$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'opt_ar'

require 'minitest/autorun'
require 'minitest/reporters'
require_relative 'models/test_models'
require_relative './setup/mysql'
require_relative 'base'


WARN_MSG = 'WARNING :: Trying to access attr that was not requested'.freeze
EMPLOYEE = 'Employee'.freeze

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new,
                          Minitest::Reporters::ProgressReporter.new]
