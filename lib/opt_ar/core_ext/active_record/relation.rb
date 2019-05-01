module ActiveRecord
  class Relation
    def opt_ar_objects(options = {})
      to_a.opt_ar_objects(options)
    end
  end
end
