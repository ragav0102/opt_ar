# Test cases covering OARs generated through invocations on
#   ActiveRecord::Relation's
class ARRelationTest < OptARTest::Base
  def setup
    super
    @relation = Employee.where('1=1')
  end

  def test_relation_count_without_req_attributes
    ar_count = @relation.count
    optars = @relation.opt_ar_objects
    optar_count = optars.length
    assert_equal ar_count, optar_count
  end

  def test_relation_count_with_req_attributes
    ar_count = @relation.count
    optars = @relation.opt_ar_objects(req_attributes: [:last_name])
    optar_count = optars.length
    assert_equal ar_count, optar_count
  end

  def test_relation_attributes_without_req_attributes
    optars = @relation.opt_ar_objects
    assert_equal optars.first.attributes.keys, [:emp_id]
  end

  def test_relation_attributes_with_req_attributes
    optars = @relation.opt_ar_objects(req_attributes: [:last_name])
    assert_equal optars.first.attributes.keys.sort, %i[emp_id last_name]
  end

  def test_relation_klass_name_without_req_attributes
    optars = @relation.opt_ar_objects
    assert_equal optars.first.klass_name, EMPLOYEE
  end

  def test_relation_klass_name_with_req_attributes
    optars = @relation.opt_ar_objects(req_attributes: [:last_name])
    assert_equal optars.first.klass_name, EMPLOYEE
  end

  def test_relation_klass_object_nil_without_req_attributes
    optars = @relation.opt_ar_objects
    assert_nil optars.first.klass_object
  end

  def test_relation_klass_object_nil_with_req_attributes
    optars = @relation.opt_ar_objects(req_attributes: [:last_name])
    assert_nil optars.first.klass_object
  end

  def test_relation_klass_object_load_without_req_attributes
    optars = @relation.opt_ar_objects
    optar = optars.first
    optar.birth_date
    refute_nil optars.first.klass_object
  end

  def test_relation_klass_object_load_with_req_attributes
    optars = @relation.opt_ar_objects(req_attributes: [:last_name])
    optar = optars.first
    optar.birth_date
    refute_nil optars.first.klass_object
  end

  def test_relation_attr_read_with_select_not_including_primary_key
    rel1 = @relation.select([:first_name])
    optars = rel1.opt_ar_objects(req_attributes: %i[first_name created_at])
    refute_nil optars.first.last_name
  end

  def test_relation_attr_read_with_select_not_including_req_attribute
    rel1 = @relation.select([:first_name])
    optars = rel1.opt_ar_objects(req_attributes: [:last_name])
    refute_nil optars.first.last_name
  end
end
