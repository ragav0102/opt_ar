require 'benchmark/memory'

def bm_time
  old_logger = ActiveRecord::Base.logger
  ActiveRecord::Base.logger = nil
  Benchmark.bm(12) do |x|
    x.report('AR') do
      emps = Employee.male_employees.to_a
      Marshal.dump(emps)
    end

    x.report('AR select') do
      emps = Employee.male_employees.select(%i[emp_id first_name last_name]).to_a
      Marshal.dump(emps)     
    end

    x.report('OptAR') do
      emps = Employee.male_employees.optars
      Marshal.dump(emps)
    end

    x.report('OptAR req') do
      emps = Employee.male_employees.optars(
        req_attribute: %i[emp_id first_name last_name]
      )
      Marshal.dump(emps)
    end
  end
  ActiveRecord::Base.logger = old_logger

  nil
end

def bm_mem
  old_logger = ActiveRecord::Base.logger
  ActiveRecord::Base.logger = nil

  Benchmark.memory do |x|
    x.compare!
    x.report('AR') do
      emps = Employee.male_employees.to_a
      Marshal.dump(emps)
    end

    x.report('AR select') do
      emps = Employee.male_employees.select(%i[emp_id first_name last_name]).to_a
      Marshal.dump(emps)     
    end

    x.report('OptAR') do
      emps = Employee.male_employees.optars
      Marshal.dump(emps)
    end

    x.report('OptAR req') do
      emps = Employee.male_employees.optars(
        req_attribute: %i[emp_id first_name last_name]
      )
      Marshal.dump(emps)
    end
  end
  ActiveRecord::Base.logger = old_logger

  nil
end

#                   AR    20.771M memsize (     1.208k retained)
#                        232.563k objects (     1.000  retained)
#                         50.000  strings (     0.000  retained)
#            AR select     8.314M memsize (     1.208k retained)
#                        105.451k objects (     1.000  retained)
#                         50.000  strings (     0.000  retained)
#                OptAR     6.227M memsize (     1.208k retained)
#                         88.802k objects (     1.000  retained)
#                         25.000  strings (     0.000  retained)
#            OptAR req     6.227M memsize (     1.208k retained)
#                         88.803k objects (     1.000  retained)
#                         25.000  strings (     0.000  retained)

# Comparison:
#                OptAR:    6226520 allocated
#            OptAR req:    6226752 allocated - 1.00x more
#            AR select:    8313821 allocated - 1.34x more
#                   AR:   20771357 allocated - 3.34x more

#                    user     system      total        real
# AR             0.350000   0.010000   0.360000 (  0.377849)
# AR select      0.170000   0.010000   0.180000 (  0.185033)
# OptAR          0.060000   0.000000   0.060000 (  0.075719)
# OptAR req      0.080000   0.010000   0.090000 (  0.087333)

#                    user     system      total        real
# AR             0.320000   0.000000   0.320000 (  0.343211)
# AR select      0.200000   0.010000   0.210000 (  0.209019)
# OptAR          0.060000   0.000000   0.060000 (  0.075407)
# OptAR req      0.070000   0.000000   0.070000 (  0.076678)
