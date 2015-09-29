module OpenStax
  module RescueFrom
    class Logger
      attr_reader :proxy

      def initialize(proxy)
        @proxy = proxy
      end

      def record_system_error!(prefix = "An exception occurred")
        Rails.logger.error("#{prefix}: #{proxy.name} [#{proxy.error_id}] " +
                           "<#{proxy.message}> #{proxy.extras}\n\n" +
                           "#{proxy.backtrace}")

        record_system_error_recursively!
      end

      private
      def record_system_error_recursively!
        if proxy.cause
          RescueFrom.register_exception(proxy.cause.class)
          @proxy = ExceptionProxy.new(proxy.cause)
          record_system_error!("Exception cause")
        end
      end
    end
  end
end
