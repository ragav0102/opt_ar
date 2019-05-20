require 'benchmark/ips'

old_logger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil

emps = Employee.all.to_a
@m1 = Marshal.dump(emps)

emps = Employee.all.select(%i[emp_id first_name last_name created_at]).to_a
@m2 = Marshal.dump(emps)

emps = Employee.all.optars
@m3 = Marshal.dump(emps)

emps = Employee.all.optars(
  req_attribute %i[emp_id first_name last_name created_at]
)
@m4 = Marshal.dump(emps)

Benchmark.ips do |x|
  x.time = 5
  x.warmup = 2

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

  x.compare!
end

ActiveRecord::Base.logger = old_logger

# Warming up --------------------------------------
#                   AR     1.000  i/100ms
#            AR select     1.000  i/100ms
#                OptAR     2.000  i/100ms
#            OptAR req     2.000  i/100ms
# Calculating -------------------------------------
#                   AR      1.130  (± 0.0%) i/s -      6.000  in   5.394933s
#            AR select      1.820  (± 0.0%) i/s -     10.000  in   5.620499s
#                OptAR     21.157  (±18.9%) i/s -    104.000  in   5.088126s
#            OptAR req     20.879  (±19.2%) i/s -    102.000  in   5.099266s

# Comparison:
#                OptAR:       21.2 i/s
#            OptAR req:       20.9 i/s - same-ish: difference falls within error
#            AR select:        1.8 i/s - 11.62x  slower
#                   AR:        1.1 i/s - 18.72x  slower
