# Test cases covering OARs generated through swindle defs
class ShowAsTest < OptARTest::Base
  def test_swindle_with_scope
    ar_count = Employee.male_employees.count
    optar_count = Employee.male_name.length
    assert_equal ar_count, optar_count
  end

  def test_swindle_without_scope
    ar_count = Employee.all.count
    optar_count = Employee.date_infos.length
    assert_equal ar_count, optar_count
  end

  def test_swindle_overriding_default_scope
    ar_count = Employee.all_emp.count
    optar_count = Employee.all_emps.length
    assert_equal ar_count, optar_count
  end

  def test_swindle_without_req_attributes
    ar_count = Employee.female_employees.count
    optar_count = Employee.female_ids.length
    assert_equal ar_count, optar_count
  end

  def test_swindle_attributes_with_scope
    male_name_attrs = %i[emp_id first_name last_name]
    optar = Employee.male_name.first
    assert_equal optar.attributes.keys.length, male_name_attrs.length
    include_all = male_name_attrs.all? { |k| optar.attributes.key?(k) }
    assert include_all
  end

  def test_swindle_attributes_without_scope
    date_infos_attrs = %i[emp_id birth_date hire_date]
    optar = Employee.date_infos.first
    assert_equal optar.attributes.keys.length, date_infos_attrs.length
    include_all = date_infos_attrs.all? { |k| optar.attributes.key?(k) }
    assert include_all
  end

  def test_swindle_attributes_overriding_default_scope
    all_emps_attrs = %i[emp_id]
    optar = Employee.all_emps.first
    assert_equal optar.attributes.keys.length, all_emps_attrs.length
    include_all = all_emps_attrs.all? { |k| optar.attributes.key?(k) }
    assert include_all
  end

  def test_swindle_attributes_without_req_attributes
    female_ids_attrs = %i[emp_id]
    optar = Employee.female_ids.first
    assert_equal optar.attributes.keys.length, female_ids_attrs.length
    include_all = female_ids_attrs.all? { |k| optar.attributes.key?(k) }
    assert include_all
  end

  def test_swindle_klass_name_with_scope
    optar = Employee.male_name.first
    assert_equal optar.klass_name, EMPLOYEE
  end

  def test_swindle_klass_name_without_scope
    optar = Employee.date_infos.first
    assert_equal optar.klass_name, EMPLOYEE
  end

  def test_swindle_klass_name_overriding_default_scope
    optar = Employee.all_emps.first
    assert_equal optar.klass_name, EMPLOYEE
  end

  def test_swindle_klass_name_without_req_attributes
    optar = Employee.female_ids.first
    assert_equal optar.klass_name, EMPLOYEE
  end

  def test_klass_object_load_on_missing_attribute
    optar = Employee.female_ids.first
    optar.first_name
    refute_nil optar.klass_object
  end

  def test_klass_object_nil_on_requested_attribute
    optar = Employee.date_infos.first
    optar.birth_date
    assert_nil optar.klass_object
  end

  def test_swindle_error_on_duplicate_method_name
    assert_raises OptAR::Errors::DuplicateNameError do
      Employee.send(:swindle, :all_emp)
    end
  end

  def test_swindle_error_on_invalid_scope
    assert_raises OptAR::Errors::UndefinedScopeError do
      Employee.send(:swindle, :sample, scope: :some_invalid)
    end
  end
end
