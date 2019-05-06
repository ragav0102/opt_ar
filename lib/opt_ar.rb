require 'opt_ar/version'
require 'active_record'
require_relative './opt_ar/optimal_ar/builder'
require_relative 'opt_ar/logger'
require_relative 'opt_ar/errors'
require_relative 'opt_ar/core_ext/active_record/relation'
# Dir['/opt_ar/core_ext/*/*.rb'].each { |file| require file }
# Dir["#{File.dirname(__FILE__)}/lib/opt_ar/**/*.rb"].each { |f| require f }

# Base module
module OptAR
end

ActiveRecord::Base.send :include, OptAR::OptimalAR::Builder

module ActiveRecord
  # Extending ActiveRecord::Relation to respond to opt_ar_objects
  class Relation
    include ActiveRecord::RelationExtender
  end
end

# Overwriting Array to make opt_ar_objects method available
#   for all arrays containing ActiveRecord::Base objects, returning
#   an array of `OAR`s which we generate
class Array
  def opt_ar_objects(options = {})
    map do |obj|
      unless obj.is_a? ActiveRecord::Base
        raise OptAR::Errors::NonActiveRecordError
      end
      obj.opt_ar_object(options)
    end
  end
end

# TODO: Implement opt_ar_objects for hash
# class Hash
#   def opt_ar_objects

#   end
# end
