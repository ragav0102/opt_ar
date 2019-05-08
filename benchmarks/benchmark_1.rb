require 'benchmark/memory'

def bm_time
  old_logger = ActiveRecord::Base.logger
  ActiveRecord::Base.logger = nil
  Benchmark.bm(12) do |x|
    x.report('AR') do
      emp = Employee.all.to_a
      emp.last.emp_id
    end

    x.report('AR select') do
      emp = Employee.all.select(%i[emp_id first_name last_name created_at]).to_a
      emp.last.emp_id
    end

    x.report('OptAR') do
      emp = Employee.all.opt_ar_objects
      emp.last.emp_id
    end

    x.report('OptAR req') do
      emp = Employee.all.opt_ar_objects(
        req_attribute: %i[emp_id first_name last_name created_at]
      )
      emp.last.emp_id
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
      emp = Employee.all.to_a
      emp.last.emp_id
    end

    x.report('AR select') do
      emp = Employee.all.select(%i[emp_id first_name last_name created_at]).to_a
      emp.last.emp_id
    end

    x.report('OptAR') do
      emp = Employee.all.opt_ar_objects
      emp.last.emp_id
    end

    x.report('OptAR req') do
      emp = Employee.all.opt_ar_objects(
        req_attribute: %i[emp_id first_name last_name created_at]
      )
      emp.last.emp_id
    end
  end
  ActiveRecord::Base.logger = old_logger

  nil
end

bm_time

bm_mem

# 1042 objects:
#                   AR     2.173M memsize (     1.208k retained)
#                         22.114k objects (     1.000  retained)
#                         50.000  strings (     0.000  retained)
#            AR select     1.326M memsize (     1.208k retained)
#                         15.938k objects (     1.000  retained)
#                         50.000  strings (     0.000  retained)
#                OptAR     1.054M memsize (     1.208k retained)
#                         14.840k objects (     1.000  retained)
#                         19.000  strings (     0.000  retained)
#            OptAR req     1.054M memsize (     1.208k retained)
#                         14.841k objects (     1.000  retained)
#                         19.000  strings (     0.000  retained)

# Comparison:
#                OptAR:    1053649 allocated
#            OptAR req:    1053913 allocated - 1.00x more
#            AR select:    1326421 allocated - 1.26x more
#                   AR:    2172969 allocated - 2.06x more

#                    user     system      total        real
# AR             0.020000   0.000000   0.020000 (  0.028664)
# AR select      0.020000   0.000000   0.020000 (  0.022151)
# OptAR          0.010000   0.000000   0.010000 (  0.010412)
# OptAR req      0.010000   0.000000   0.010000 (  0.010862)

# AR             0.020000   0.000000   0.020000 (  0.029021)
# AR select      0.030000   0.000000   0.030000 (  0.028373)
# OptAR          0.010000   0.000000   0.010000 (  0.012695)
# OptAR req      0.010000   0.000000   0.010000 (  0.011037)

# 11042 objects:
#                   AR    22.809M memsize (     1.208k retained)
#                        232.114k objects (     1.000  retained)
#                         50.000  strings (     0.000  retained)
#            AR select    13.802M memsize (     1.208k retained)
#                        165.938k objects (     1.000  retained)
#                         50.000  strings (     0.000  retained)
#                OptAR    10.972M memsize (     1.208k retained)
#                        154.840k objects (     1.000  retained)
#                         19.000  strings (     0.000  retained)
#            OptAR req    10.972M memsize (     1.208k retained)
#                        154.841k objects (     1.000  retained)
#                         19.000  strings (     0.000  retained)

# Comparison:
#                OptAR:   10971521 allocated
#            OptAR req:   10971785 allocated - 1.00x more
#            AR select:   13802165 allocated - 1.26x more
#                   AR:   22808713 allocated - 2.08x more

#                    user     system      total        real
# AR             0.210000   0.010000   0.220000 (  0.235152)
# AR select      0.200000   0.010000   0.210000 (  0.217465)
# OptAR          0.090000   0.000000   0.090000 (  0.105298)
# OptAR req      0.070000   0.010000   0.080000 (  0.088627)

# AR             0.210000   0.010000   0.220000 (  0.235152)
# AR select      0.200000   0.010000   0.210000 (  0.217465)
# OptAR          0.090000   0.000000   0.090000 (  0.105298)
# OptAR req      0.070000   0.010000   0.080000 (  0.088627)
