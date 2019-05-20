# Tests versioning and DB bootstrap for tests
class OptARArrayTest < OptARTest::Base
  def setup
    super
    @arr = Employee.male_employees.to_a
  end

  def test_array_optar_with_ars
    objs = @arr.optars
    assert(objs.all? { |obj| obj.is_a?(OptAR::OAR) })
  end

  def test_array_optar_with_non_ars_exception
    assert_raises OptAR::Errors::NonActiveRecordError do
      @arr << 'invalid OAR'
      @arr.optars
    end
  end
end
