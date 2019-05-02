module OptAR
  # Log implementation for the gem
  #
  # Tries to use ActiveRecord::Base.logger which is compatible with rails
  #   else, fallbacks to STDOUT
  module Logger
    class << self
      def log(msg, level = :info)
        logger.send(level, msg)
      end

      def logger
        ActiveRecord::Base.logger || ::Logger.new(STDOUT)
      end
    end
  end
end
