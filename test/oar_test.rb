require_relative 'test_helper'

# Tests versioning and DB bootstrap for tests
class OARTest < OptARTest::Base
  def setup
    super
    @oar = OptAR::OAR.new(Employee.first)
    @oar_attrs = OptAR::OAR.new(
      Employee.first,
      req_attributes: %i[birth_date first_name]
    )
  end

  def test_oar_attributes_immutability
    assert_raises OptAR::Errors::MutationNotAllowedError do
      @oar.attributes = { last_name: 'Green' }
    end
  end

  def test_oar_attributes_key_immutability
    err = assert_raises RuntimeError do
      @oar.attributes[:last_name] = 'Green'
    end
    assert_match(/can't modify frozen Hash/, err.message)
  end

  def test_oar_klass_name_immutability
    assert_raises OptAR::Errors::MutationNotAllowedError do
      @oar.klass_name = 'Rachel::Green'
    end
  end

  def test_oar_klass_object_immutability
    assert_raises ActiveRecord::ReadOnlyRecord do
      @oar.first_name
      @oar.klass_object.emp_id = 101_010
      @oar.klass_object.save
    end
  end

  def test_oar_equations_immutability
    assert_raises OptAR::Errors::MutationNotAllowedError do
      @oar.first_name = 'Rachel'
    end
  end

  def test_oar_ar_not_found_error
    assert_raises OptAR::Errors::ARObjectNotFoundError do
      emp = Employee.new(first_name: 'Chandler', last_name: 'M. Bing',
                         birth_date: '1960-03-21', hire_date: '1994-04-12',
                         gender: 1, emp_id: Employee.maximum(:emp_id) + 100,
                         password: 'oprjeiw')
      emp.save!
      oar1 = emp.opt_ar_object
      emp.destroy
      oar1.last_name
    end
  end

  def test_blacklisted_attrs_removal
    oar1 = Employee.first.opt_ar_object(req_attributes: [:password])
    refute oar1.attributes.key?(:password)
  end

  def test_exception_for_blacklisting_primary_key
    assert_raises OptAR::Errors::PrimaryKeyBlacklistedError do
      OptAR::OAR.new(SampleAR.new(sample_id: 21))
    end
  end

  def test_valid_datetime_ar_field_transform
    emp = Employee.last
    oar1 = emp.opt_ar_object(req_attributes: [:created_at])
    assert emp.created_at == oar1.created_at
  end

  def test_valid_datetime_ar_field_transform_overriding
    Employee.stub_const(:DATE_TIME_ATTRIBUTES, %i[created_at]) do
      emp = Employee.last
      oar1 = emp.opt_ar_object(req_attributes: [:created_at])
      assert emp.created_at == oar1.created_at
    end
  end

  def test_exception_for_invalid_datetime_attribute
    assert_raises OptAR::Errors::TimeTypeExpectedError do
      Employee.stub_const(:DATE_TIME_ATTRIBUTES, %i[first_name]) do
        emp = Employee.last
        emp.opt_ar_object(req_attributes: [:first_name])
      end
    end
  end

  def test_exception_for_init_without_primary_key
    assert_raises OptAR::Errors::MandatoryPrimaryKeyMissingError do
      Employee.select([:first_name]).first.opt_ar_object
    end
  end
end
