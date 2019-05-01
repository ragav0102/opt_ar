require 'opt_ar/version'
require 'active_record'
require_relative './opt_ar/optimal_ar/builder'
# Dir["#{File.dirname(__FILE__)}/lib/opt_ar/**/*.rb"].each { |f| require f }

module OptAR
end

ActiveRecord::Base.send :include, OptAR::OptimalAR::Builder

module ActiveRecord
  class Relation
    def opt_ar_objects(options = {})
      to_a.opt_ar_objects(options)
    end
  end
end

class Array
  def opt_ar_objects(options = {})
    map { |obj| obj.opt_ar_object(options) }
  end
end
