require 'test_helper'

class OptARTest < Minitest::Test
  def test_version_number_presence
    refute_nil ::OptAR::VERSION
  end

  def test_it_does_something_useful
    assert true
  end
end
