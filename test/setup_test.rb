# Tests versioning and DB bootstrap for tests
class SetupTest < OptarTest::Base
  def test_version_number_presence
    refute_nil ::OptAR::VERSION
  end

  def test_db_table_exists_with_data
    assert !Employee.count.zero?
  end
end
