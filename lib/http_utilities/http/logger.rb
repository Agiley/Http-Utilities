module HttpUtilities
  module Http
    module Logger
      
      def log(level, message)
        (defined?(Rails) && Rails.logger) ? Rails.logger.send(level, message) : puts(message)
      end
      
    end
  end
end