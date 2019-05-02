module OptAR
  module Errors
    class UndefinedScopeError < StandardError
    end

    class DuplicateNameError < StandardError
    end

    class MutationNotAllowedError < StandardError
    end

    class ARObjectNotFoundError < StandardError
    end

    class MissingPrimaryKeyError < StandardError
    end

    class NonActiveRecordError < StandardError
    end
  end
end
