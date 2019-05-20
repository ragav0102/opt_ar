require 'opt_ar/version'
require 'active_record'
require_relative './opt_ar/optimal_ar/builder'
require_relative 'opt_ar/logger'
require_relative 'opt_ar/errors'
require_relative 'opt_ar/core_ext/active_record/relation'
require_relative 'opt_ar/core_ext/array'
# Dir['/opt_ar/core_ext/*/*.rb'].each { |file| require file }
# Dir["#{File.dirname(__FILE__)}/lib/opt_ar/**/*.rb"].each { |f| require f }

# Base module
module OptAR
end

ActiveRecord::Base.send :include, OptAR::OptimalAR::Builder

module ActiveRecord
  # Extending ActiveRecord::Relation to respond to optars
  class Relation
    include ActiveRecord::RelationExtender
  end
end

# Overwriting Array to make optars method available
#   for all arrays containing ActiveRecord::Base objects, returning
#   an array of `OAR`s which we generate
class Array
  include ArrayExtender
end

# TODO: Implement optars for hash
# class Hash
#   def optars

#   end
# end
