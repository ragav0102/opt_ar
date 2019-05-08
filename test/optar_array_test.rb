# Tests versioning and DB bootstrap for tests
class OptARArrayTest < OptARTest::Base
  def setup
    super
    @arr = Employee.male_employees.to_a
  end

  def test_array_optar_with_ars
    optars = @arr.opt_ar_objects
    assert(optars.all? { |optar| optar.is_a?(OptAR::OAR) })
  end

  def test_array_optar_with_non_ars_exception
    assert_raises OptAR::Errors::NonActiveRecordError do
      @arr << 'invalid OAR'
      @arr.opt_ar_objects
    end
  end
end
