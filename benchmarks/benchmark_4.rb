require 'benchmark/memory'

def bm_time
  old_logger = ActiveRecord::Base.logger
  ActiveRecord::Base.logger = n
  Benchmark.bm(12) do |x|
    x.report('AR') do
      emps = Employee.all.to_a
      Marshal.dump(emps)
    end

    x.report('AR select') do
      emps = Employee.all.select([:emp_id, :first_name, :last_name, :created_at]).to_a
      Marshal.dump(emps)     
    end

    x.report('OptAR') do
      emps = Employee.all.optars
      Marshal.dump(emps)
    end

    x.report('OptAR req') do
      emps = Employee.all.optars(
        req_attribute: [:emp_id, :first_name, :last_name, :created_at]
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
      emps = Employee.all.to_a
      Marshal.dump(emps)     
    end

    x.report('AR select') do
      emps = Employee.all.select([:emp_id, :first_name, :last_name, :created_at]).to_a
      Marshal.dump(emps)     
    end

    x.report('OptAR') do
      emps = Employee.all.optars
      Marshal.dump(emps)
    end

    x.report('OptAR req') do
      emps = Employee.all.optars(
        req_attribute: [:emp_id, :first_name, :last_name, :created_at]
      )
      Marshal.dump(emps)
    end
  end
  ActiveRecord::Base.logger = old_logger

  nil
end

bm_time

bm_mem


#                    user     system      total        real
# AR             0.660000   0.000000   0.660000 (  0.692568)
# AR select      0.480000   0.010000   0.490000 (  0.492313)
# OptAR          0.140000   0.010000   0.150000 (  0.152383)
# OptAR req      0.150000   0.000000   0.150000 (  0.168766)

#                    user     system      total        real
# AR             0.690000   0.010000   0.700000 (  0.713360)
# AR select      0.490000   0.010000   0.500000 (  0.505020)
# OptAR          0.150000   0.010000   0.160000 (  0.163765)
# OptAR req      0.160000   0.000000   0.160000 (  0.169661)

#                   AR    41.403M memsize (     1.208k retained)
#                        464.023k objects (     1.000  retained)
#                         50.000  strings (     0.000  retained)
#            AR select    23.144M memsize (     1.208k retained)
#                        298.469k objects (     1.000  retained)
#                         50.000  strings (     0.000  retained)
#                OptAR    12.379M memsize (     1.208k retained)
#                        176.924k objects (     1.000  retained)
#                         20.000  strings (     0.000  retained)
#            OptAR req    12.379M memsize (     1.208k retained)
#                        176.925k objects (     1.000  retained)
#                         20.000  strings (     0.000  retained)

# Comparison:
#                OptAR:   12379226 allocated
#            OptAR req:   12379490 allocated - 1.00x more
#            AR select:   23144122 allocated - 1.87x more
#                   AR:   41403038 allocated - 3.34x more
