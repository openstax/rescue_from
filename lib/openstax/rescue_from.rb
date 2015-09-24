require 'openstax/rescue_from/configuration'

module OpenStax
  module RescueFrom
    class << self
      @@registered_exceptions = []
      @@non_notifying_exceptions = []
      @@friendly_status_messages = {}
      @@exception_status_codes = {}
      @@exception_extras = {}

      def perform_rescue(exception:, listener: MuteListener.new)
        proxy = ExceptionProxy.new(exception)

        listener.before_openstax_exception_rescue(proxy)
        log_system_error(proxy)
        send_notifying_exceptions(proxy, listener)
        finish_exception_rescue(proxy, listener)
      end

      def registered_exceptions
        @@registered_exceptions
      end

      def non_notifying_exceptions
        @@non_notifying_exceptions
      end

      def friendly_status_messages
        @@friendly_status_messages
      end

      def exception_status_codes
        @@exception_status_codes
      end

      def exception_extras
        @@exception_extras
      end

      def register_exception(exception, options = {})
        options.stringify_keys!
        options = { 'notify' => false,
                    'status' => :internal_server_error,
                    'extras' => ->(exception) { {} } }.merge(options)

        @@registered_exceptions << exception.name
        @@non_notifying_exceptions << exception.name unless options['notify']
        @@exception_status_codes[exception.name] = options['status']
        @@exception_extras[exception.name] = options['extras']
      end

      def translate_status_codes(map = {})
        map.each do |k, v|
          @@friendly_status_messages[k] = v
        end
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
