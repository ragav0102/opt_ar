# Extender to add functionality to Array class to make optars
#   method available for an array of ActiveRecord objects,
#   returning array of `OAR`s which we generate
module ArrayExtender
  def optars(options = {})
    map do |obj|
      unless obj.is_a? ActiveRecord::Base
        raise OptAR::Errors::NonActiveRecordError
      end
      obj.optar(options)
    end
  end

  alias opt_ar_objects optars
end
