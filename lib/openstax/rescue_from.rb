require 'openstax/rescue_from/configuration'

module OpenStax
  module RescueFrom
    class << self
      def perform_rescue(exception:, listener: MuteListener.new)
        proxy = ExceptionProxy.new(exception)

        listener.before_openstax_exception_rescue(proxy)
        log_system_error(proxy)
        send_notifying_exceptions(proxy, listener)
        finish_exception_rescue(proxy, listener)
      end

      def configure
        yield configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end

      private
      def log_system_error(proxy)
        logger = Logger.new(proxy)
        logger.record_system_error!
      end

      def send_notifying_exceptions(proxy, listener)
        if proxy.notify?
          configuration.notifier.notify_exception(
            proxy.exception,
            env: listener.request.env,
            data: {
              error_id: proxy.error_id,
              :class => proxy.name,
              message: proxy.message,
              first_line_of_backtrace: proxy.first_backtrace_line,
              cause: proxy.cause,
              dns_name: proxy.dns_name,
              extras: proxy.extras
            },
            sections: %w(data request session environment backtrace)
          )
        end
      end

      def finish_exception_rescue(proxy, listener)
        if configuration.raise_exceptions
          raise proxy.exception
        else
          listener.after_openstax_exception_rescue(proxy)
        end
      end
    end
  end
end
