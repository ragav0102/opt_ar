# Sample ActiveRecord model used for test cases
class Employee < ActiveRecord::Base
  self.table_name =  'employee'.freeze
  self.primary_key = 'emp_id'.freeze

  BLACKLISTED_ATTRIBUTES = %i[password].freeze

  default_scope lambda {
    where("hire_date >= '1990-01-01'")
      .order(:hire_date)
  }

  scope :female_employees, lambda {
    where(gender: 0)
  }

  scope :male_employees, lambda {
    where(gender: 1)
  }

  scope :all_emp, lambda {
    unscoped
  }

  swindle :male_name,
          scope: :male_employees,
          attrs: %i[emp_id first_name last_name]

  swindle :date_infos,
          attrs: %i[birth_date hire_date]

  swindle :all_emps,
          scope: :all_emp

  swindle :female_ids,
          scope: :female_employees
end

# Test ActiveRecord class with primary key as blacklisted_attribute
class SampleAR < ActiveRecord::Base
  self.primary_key = 'sample_id'
  self.table_name = 'sample_ar'

  BLACKLISTED_ATTRIBUTES = [:sample_id].freeze

  swindle :error_out
end
