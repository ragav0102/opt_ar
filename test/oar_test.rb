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

  def test_with_no_blacklisted_attrs_defined
    prev = Employee.const_get(:BLACKLISTED_ATTRIBUTES)
    Employee.send(:remove_const, :BLACKLISTED_ATTRIBUTES)
    oar1 = Employee.first.opt_ar_object(req_attributes: [:password])
    assert oar1.attributes.key?(:password)
  ensure
    Employee.const_set(:BLACKLISTED_ATTRIBUTES, prev)
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

  def test_respond_to_check_for_unrequested_attribute
    assert @oar.respond_to?(:created_at)
  end

  def test_respond_to_check_for_invalid_attribute
    refute @oar.respond_to?(:created_at_e98qwe)
  end

  def test_respond_to_check_for_req_attribute
    assert @oar.respond_to?(:emp_id)
  end

  def test_marshal_dump_attributes_retaining
    m = Marshal.dump(@oar)
    um = Marshal.load(m)
    assert_equal um.attributes, @oar.attributes
  end

  def test_marshal_dump_klass_name_retaining
    m = Marshal.dump(@oar)
    um = Marshal.load(m)
    assert_equal um.klass_name, @oar.klass_name
  end

  def test_marshal_dump_klass_object_removal
    @oar.first_name
    assert !@oar.instance_variable_get('@klass_object').nil?
    m = Marshal.dump(@oar)
    um = Marshal.load(m)
    assert um.instance_variable_get('@klass_object').nil?
  end

  def test_marshal_dump_primary_key_removal
    @oar.first_name
    assert !@oar.instance_variable_get('@primary_key').nil?
    m = Marshal.dump(@oar)
    um = Marshal.load(m)
    assert um.instance_variable_get('@primary_key').nil?
  end

  def test_as_json
    stub = { @oar.send(:klass_key) => @oar.attributes.stringify_keys }
    assert @oar.as_json == stub
  end

  def test_to_json
    stub = JSON.dump(@oar.send(:klass_key) => @oar.attributes.as_json)
    assert_match @oar.to_json, stub
  end
end
