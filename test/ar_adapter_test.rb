require_relative 'base'

# Tests all invocations from an ActiveRecord object
class ARAdapterTest < OptARTest::Base
  def test_optar_response_to_primary_key
    optar = Employee.first.optars
    refute_nil(optar.emp_id)
  end

  def test_optar_response_to_unrequested_attr
    optar = Employee.first.optars
    refute_nil(optar.last_name)
  end

  def test_warning_for_unrequested_attr
    optar = Employee.first.optars
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
    optar = Employee.first.optars
    assert_equal ar.emp_id, optar.emp_id
  end

  def test_optar_attributes_with_req_attributes
    ar = Employee.first
    optar = ar.optar(attrs: %i[emp_id birth_date first_name])
    assert_equal ar.emp_id, optar.emp_id
    assert_equal ar.birth_date, optar.birth_date
    assert_equal optar.attributes.length, 3
  end

  def test_optar_klass_name_with_req_attributes
    ar = Employee.first
    optar = ar.optar(attrs: %i[emp_id birth_date first_name])
    assert_equal optar.klass_name, EMPLOYEE
  end

  def test_optar_klass_object_nil_with_req_attributes
    ar = Employee.first
    optar = ar.optar(attrs: %i[emp_id birth_date first_name])
    assert_nil optar.klass_object
    optar.last_name
    refute_nil optar.klass_object
  end

  def test_optar_attributes_without_req_attributes
    ar = Employee.first
    optar = ar.optar
    assert_equal ar.emp_id, optar.emp_id
    assert_equal ar.birth_date, optar.birth_date
    assert_equal optar.attributes.length, 1
  end

  def test_optar_klass_name_without_req_attributes
    ar = Employee.first
    optar = ar.optar
    assert_equal optar.klass_name, EMPLOYEE
  end

  def test_optar_klass_object_nil_without_req_attributes
    ar = Employee.first
    optar = ar.optar
    assert_nil optar.klass_object
    optar.last_name
    refute_nil optar.klass_object
  end
end
