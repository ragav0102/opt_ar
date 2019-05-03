require_relative 'test_helper'

module OptARTest
  # Base class where all generic test logics go
  class Base < Minitest::Test
    def setup
      log_path = "#{File.expand_path(Dir.pwd)}/logs/test.log"
      ActiveRecord::Base.logger = Logger.new(log_path)
    end
  end
end
