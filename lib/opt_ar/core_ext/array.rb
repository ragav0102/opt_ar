class Array
  def opt_ar_objects(options = {})
    map { |obj| obj.opt_ar_object(options) }
  end
end
