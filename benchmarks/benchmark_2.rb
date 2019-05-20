require 'benchmark/memory'

def bm_time
  old_logger = ActiveRecord::Base.logger
  ActiveRecord::Base.logger = nil
  Benchmark.bm(12) do |x|
    x.report('AR') do
      emps = Employee.male_employees.to_a
      emps.last.emp_id 
    end

    x.report('AR select') do
      emps = Employee.male_employees.select(%i[emp_id first_name last_name]).to_a
      emps.last.emp_id
    end

    x.report('OptAR') do
      emps = Employee.male_employees.optars
      emps.last.emp_id
    end

    x.report('OptAR req') do
      emps = Employee.male_employees.optars(
        req_attribute: %i[emp_id first_name last_name]
      )
      emps.last.emp_id
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
      emps.last.emp_id 
    end

    x.report('AR select') do
      emps = Employee.male_employees.select(%i[emp_id first_name last_name]).to_a
      emps.last.emp_id
    end

    x.report('OptAR') do
      emps = Employee.male_employees.optars
      emps.last.emp_id
    end

    x.report('OptAR req') do
      emps = Employee.male_employees.optars(
        req_attribute: %i[emp_id first_name last_name]
      )
      emps.last.emp_id
    end
  end
  ActiveRecord::Base.logger = old_logger

  nil
end

bm_time

bm_mem

#                   AR    11.375M memsize (     1.208k retained)
#                        116.427k objects (     1.000  retained)
#                         50.000  strings (     0.000  retained)
#            AR select     5.716M memsize (     1.208k retained)
#                         66.721k objects (     1.000  retained)
#                         50.000  strings (     0.000  retained)
#                OptAR     5.522M memsize (     1.208k retained)
#                         77.744k objects (     1.000  retained)
#                         24.000  strings (     0.000  retained)
#            OptAR req     5.522M memsize (     1.208k retained)
#                         77.745k objects (     1.000  retained)
#                         24.000  strings (     0.000  retained)

# Comparison:
#                OptAR:    5521999 allocated
#            OptAR req:    5522231 allocated - 1.00x more
#            AR select:    5715872 allocated - 1.04x more
#                   AR:   11374672 allocated - 2.06x more

#                    user     system      total        real
# AR             0.120000   0.000000   0.120000 (  0.129684)
# AR select      0.070000   0.010000   0.080000 (  0.081367)
# OptAR          0.050000   0.000000   0.050000 (  0.056168)
# OptAR req      0.040000   0.000000   0.040000 (  0.057154)

#                    user     system      total        real
# AR             0.180000   0.010000   0.190000 (  0.218083)
# AR select      0.090000   0.000000   0.090000 (  0.101246)
# OptAR          0.050000   0.000000   0.050000 (  0.061082)
# OptAR req      0.050000   0.000000   0.050000 (  0.056118)