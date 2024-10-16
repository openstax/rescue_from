module OpenStax
  module RescueFrom
    class Logger
      attr_reader :exception_proxy, :logger

      def initialize(exception_proxy, logger = Rails.logger)
        @exception_proxy = exception_proxy
        @logger = logger
      end

      def record_system_error!(prefix = "An exception occurred")
        logger.error("#{prefix}: #{exception_proxy.name} [#{exception_proxy.error_id}] " +
                     "<#{exception_proxy.message}> #{exception_proxy.extras}\n\n" +
                     "#{exception_proxy.logger_backtrace}")

        record_system_error_recursively!
      end

      private
      def record_system_error_recursively!
        if exception_proxy.cause
          RescueFrom.register_unrecognized_exception(exception_proxy.cause.class)
          @exception_proxy = ExceptionCauseProxy.new(exception_proxy.cause)
          record_system_error!("Exception cause")
        end
      end
    end
  end
end
