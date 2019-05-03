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

  show_as :male_name,
          scope: :male_employees,
          req_attributes: %i[emp_id first_name last_name]

  show_as :date_infos,
          req_attributes: %i[birth_date hire_date]

  show_as :all_emps,
          scope: :all_emp

  show_as :female_ids,
          scope: :female_employees
end

# Test ActiveRecord class with primary key as blacklisted_attribute
class SampleAR < ActiveRecord::Base
  self.primary_key = 'sample_id'
  self.table_name = 'sample_ar'

  BLACKLISTED_ATTRIBUTES = [:sample_id].freeze

  show_as :error_out
end
