require_relative 'test_helper'
require_relative './setup/mysql'
require 'byebug'

class OptARTest < Minitest::Test
  EMPLOYEE = 'Employee'.freeze

  def setup
    log_path = "#{File.expand_path(Dir.pwd)}/logs/test.log"
    FileUtils.touch(log_path)
    ActiveRecord::Base.logger = Logger.new(log_path)
  end

  def test_version_number_presence
    refute_nil ::OptAR::VERSION
  end

  def test_it_does_something_useful
    assert true
  end

  def test_db_table_exists_with_data
    assert !Employee.count.zero?
  end

  def test_optar_response_to_primary_key
    optar = Employee.first.opt_ar_objects
    refute_nil(optar.emp_id)
  end

  def test_optar_response_to_unrequested_attr
    optar = Employee.first.opt_ar_objects
    refute_nil(optar.last_name)
  end

  def test_warning_for_unrequested_attr
    optar = Employee.first.opt_ar_objects
    mock = MiniTest::Mock.new
    msg = 'WARNING :: Trying to access attr that was not requested :: gender'
    mock.expect(:call, nil, [msg, :warn])

    OptAR::Logger.stub(:log, mock) do
      optar.gender
    end

    mock.verify
  end

  def test_optar_employee_first
    ar = Employee.first
    optar = Employee.first.opt_ar_objects
    assert_equal ar.emp_id, optar.emp_id
  end

  def test_show_as_with_scope
    ar_count = Employee.male_employees.count
    optar_count = Employee.male_name.length
    assert_equal ar_count, optar_count
  end

  def test_show_as_without_scope
    ar_count = Employee.all.count
    optar_count = Employee.date_infos.length
    assert_equal ar_count, optar_count
  end

  def test_show_as_overriding_default_scope
    ar_count = Employee.all_emp.count
    optar_count = Employee.all_emps.length
    assert_equal ar_count, optar_count
  end

  def test_show_as_without_req_attributes
    ar_count = Employee.female_employees.count
    optar_count = Employee.female_ids.length
    assert_equal ar_count, optar_count
  end

  def test_show_as_attributes_with_scope
    male_name_attrs = %i[emp_id first_name last_name]
    optar = Employee.male_name.first
    assert_equal optar.attributes.keys.length, male_name_attrs.length
    include_all = male_name_attrs.all? { |k| optar.attributes.key?(k) }
    assert include_all
  end

  def test_show_as_attributes_without_scope
    date_infos_attrs = %i[emp_id birth_date hire_date]
    optar = Employee.date_infos.first
    assert_equal optar.attributes.keys.length, date_infos_attrs.length
    include_all = date_infos_attrs.all? { |k| optar.attributes.key?(k) }
    assert include_all
  end

  def test_show_as_attributes_overriding_default_scope
    all_emps_attrs = %i[emp_id]
    optar = Employee.all_emps.first
    assert_equal optar.attributes.keys.length, all_emps_attrs.length
    include_all = all_emps_attrs.all? { |k| optar.attributes.key?(k) }
    assert include_all
  end

  def test_show_as_attributes_without_req_attributes
    female_ids_attrs = %i[emp_id]
    optar = Employee.female_ids.first
    assert_equal optar.attributes.keys.length, female_ids_attrs.length
    include_all = female_ids_attrs.all? { |k| optar.attributes.key?(k) }
    assert include_all
  end

  def test_show_as_klass_name_with_scope
    optar = Employee.male_name.first
    assert_equal optar.klass_name, EMPLOYEE
  end

  def test_show_as_klass_name_without_scope
    optar = Employee.date_infos.first
    assert_equal optar.klass_name, EMPLOYEE
  end

  def test_show_as_klass_name_overriding_default_scope
    optar = Employee.all_emps.first
    assert_equal optar.klass_name, EMPLOYEE
  end

  def test_show_as_klass_name_without_req_attributes
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
    optar_first_name = optar.birth_date
    assert_nil optar.klass_object
  end
end
