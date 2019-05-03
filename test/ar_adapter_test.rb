require_relative 'test_helper'

# Tests all invocations from an ActiveRecord object
class ARAdapterTest < Minitest::Test
  def setup
    log_path = "#{File.expand_path(Dir.pwd)}/logs/test.log"
    ActiveRecord::Base.logger = Logger.new(log_path)
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

  def test_opt_ar_object_attributes_with_req_attributes
    ar = Employee.first
    optar = ar.opt_ar_object(req_attributes: %i[emp_id birth_date first_name])
    assert_equal ar.emp_id, optar.emp_id
    assert_equal ar.birth_date, optar.birth_date
    assert_equal optar.attributes.length, 3
  end

  def test_opt_ar_object_klass_name_with_req_attributes
    ar = Employee.first
    optar = ar.opt_ar_object(req_attributes: %i[emp_id birth_date first_name])
    assert_equal optar.klass_name, EMPLOYEE
  end

  def test_opt_ar_object_klass_object_nil_with_req_attributes
    ar = Employee.first
    optar = ar.opt_ar_object(req_attributes: %i[emp_id birth_date first_name])
    assert_nil optar.klass_object
    optar.last_name
    refute_nil optar.klass_object
  end

  def test_opt_ar_object_attributes_without_req_attributes
    ar = Employee.first
    optar = ar.opt_ar_object
    assert_equal ar.emp_id, optar.emp_id
    assert_equal ar.birth_date, optar.birth_date
    assert_equal optar.attributes.length, 1
  end

  def test_opt_ar_object_klass_name_without_req_attributes
    ar = Employee.first
    optar = ar.opt_ar_object
    assert_equal optar.klass_name, EMPLOYEE
  end

  def test_opt_ar_object_klass_object_nil_without_req_attributes
    ar = Employee.first
    optar = ar.opt_ar_object
    assert_nil optar.klass_object
    optar.last_name
    refute_nil optar.klass_object
  end
end
