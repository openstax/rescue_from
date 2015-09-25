require 'openstax/rescue_from/configuration'

module OpenStax
  module RescueFrom
    class << self
      def perform_rescue(exception:, listener: MuteListener.new)
        proxy = ExceptionProxy.new(exception)

        register_exception(exception.class)
        listener.before_openstax_exception_rescue(proxy)
        log_system_error(proxy)
        send_notifying_exceptions(proxy, listener)
        finish_exception_rescue(proxy, listener)
      end

      def register_exception(exception, options = {})
        unless registered_exceptions.include?(exception.name)
          options.stringify_keys!
          options = { 'notify' => true,
                      'status' => :internal_server_error,
                      'extras' => ->(exception) { {} } }.merge(options)

          registered_exceptions << exception.name
          non_notifying_exceptions << exception.name unless options['notify']
          exception_status_codes[exception.name] = options['status']
          exception_extras[exception.name] = options['extras']
        end
      end

      def translate_status_codes(map = {})
        map.each do |k, v|
          friendly_status_messages[k] = v
        end
      end

      def registered_exceptions
        @@registered_exceptions ||= []
      end

      def non_notifying_exceptions
        @@non_notifying_exceptions ||= []
      end

      def notifying_exceptions
        registered_exceptions - non_notifying_exceptions
      end

      def friendly_message(status)
        friendly_status_messages[status] || default_friendly_message
      end

      def notifies_for?(exception_name)
        notifying_exceptions.include?(exception_name)
      end

      def status(exception_name)
        exception_status_codes[exception_name]
      end

      def http_code(status)
        Rack::Utils.status_code(status)
      end

      def extras_proc(exception_name)
        exception_extras[exception_name]
      end

      def generate_id
        "%06d#{SecureRandom.random_number(10**6)}"
      end

      def configure
        yield configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end

      private
      def friendly_status_messages
        @@friendly_status_messages ||= {
          internal_server_error: default_friendly_message
        }
      end

      def exception_status_codes
        @@exception_status_codes ||= {}
      end

      def exception_extras
        @@exception_extras ||= {}
      end

      def default_friendly_message
        "Sorry, #{configuration.app_name} had some unexpected trouble with your request."
      end

      def resolve_ip(ip)
        Resolv.getname(ip) rescue 'unknown'
      end

      def log_system_error(proxy)
        logger = Logger.new(proxy)
        logger.record_system_error!
      end

      def send_notifying_exceptions(proxy, listener)
        if notifies_for?(proxy.name)
          configuration.notifier.notify_exception(
            proxy.exception,
            env: listener.request.env,
            data: {
              error_id: proxy.error_id,
              :class => proxy.name,
              message: proxy.message,
              first_line_of_backtrace: proxy.first_backtrace_line,
              cause: proxy.cause,
              dns_name: resolve_ip(listener.request.remote_ip),
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
