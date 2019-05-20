require 'benchmark/memory'

emps = Employee.all.to_a
m1 = Marshal.dump(emps) 

emps = Employee.all.select([:emp_id, :first_name, :last_name, :created_at]).to_a
m2 = Marshal.dump(emps) 

emps = Employee.all.optars
m3 = Marshal.dump(emps)

emps = Employee.all.optars(req_attribute: [:emp_id, :first_name, :last_name, :created_at])
m4 = Marshal.dump(emps)

# 2.2.3 :198 > ObjectSpace.memsize_of m1
#  => 8388649
# 2.2.3 :199 > ObjectSpace.memsize_of m2
#  => 4194345
# 2.2.3 :200 > ObjectSpace.memsize_of m3
#  => 524329
# 2.2.3 :201 > ObjectSpace.memsize_of m4
#  => 524329

def bm_time
  old_logger = ActiveRecord::Base.logger
  ActiveRecord::Base.logger = nil
  Benchmark.bm(12) do |x|
    x.report('AR') do
      Marshal.load(@m1)
    end

    x.report('AR select') do
      Marshal.load(@m2)
    end

    x.report('OptAR') do
      Marshal.load(@m3)
    end

    x.report('OptAR req') do
      Marshal.load(@m4)
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
      Marshal.load(@m1)
    end

    x.report('AR select') do
      Marshal.load(@m2)
    end

    x.report('OptAR') do
      Marshal.load(@m3)
    end

    x.report('OptAR req') do
      Marshal.load(@m4)
    end
  end
  ActiveRecord::Base.logger = old_logger

  nil
end
bm_time

bm_mem

#                    user     system      total        real
# AR             0.800000   0.120000   0.920000 (  0.926619)
# AR select      0.560000   0.000000   0.560000 (  0.565152)
# OptAR          0.050000   0.000000   0.050000 (  0.047571)
# OptAR req      0.050000   0.000000   0.050000 (  0.053500)

#                    user     system      total        real
# AR             0.850000   0.010000   0.860000 (  0.858270)
# AR select      0.560000   0.000000   0.560000 (  0.576175)
# OptAR          0.060000   0.000000   0.060000 (  0.059859)
# OptAR req      0.080000   0.000000   0.080000 (  0.074988)

#                   AR    53.890M memsize (     0.000  retained)
#                        607.395k objects (     0.000  retained)
#                         50.000  strings (     0.000  retained)
#            AR select    33.837M memsize (     0.000  retained)
#                        430.717k objects (     0.000  retained)
#                         50.000  strings (     0.000  retained)
#                OptAR     3.975M memsize (     0.000  retained)
#                         44.173k objects (     0.000  retained)
#                          4.000  strings (     0.000  retained)
#            OptAR req     3.975M memsize (     0.000  retained)
#                         44.173k objects (     0.000  retained)
#                          4.000  strings (     0.000  retained)

# Comparison:
#            OptAR req:    3975400 allocated
#                OptAR:    3975400 allocated - same
#            AR select:   33837085 allocated - 8.51x more
#                   AR:   53889558 allocated - 13.56x more
