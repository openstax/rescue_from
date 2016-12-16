require 'openstax/rescue_from/exception_options'
require 'openstax/rescue_from/controller'
require 'openstax/rescue_from/view_helpers'
require 'openstax/rescue_from/configuration'

module OpenStax
  module RescueFrom
    class << self
      def perform_rescue(exception, listener = MuteListener.new)
        proxy = ExceptionProxy.new(exception)
        register_unrecognized_exception(proxy.name)
        log_system_error(proxy)
        send_notifying_exceptions(proxy, listener)
        finish_exception_rescue(proxy, listener)
      end

      def register_exception(exception, options = {})
        name = exception.is_a?(String) ? exception : exception.name
        options = ExceptionOptions.new(options)
        @@registered_exceptions ||= {}
        @@registered_exceptions[name] = options
      end

      def register_unrecognized_exception(exception_class, options = {})
        unless registered_exceptions.keys.include?(exception_class)
          register_exception(exception_class, options)
        end
      end

      # For rescuing from specific blocks of code: OpenStax::RescueFrom.this{...}
      def this
        begin
          yield
        rescue Exception => e
          perform_rescue(e)
        end
      end

      def translate_status_codes(map = {})
        map.each do |k, v|
          friendly_status_messages[k] = v
        end
      end

      def registered_exceptions
        @@registered_exceptions.dup
      end

      def non_notifying_exceptions
        @@registered_exceptions.reject { |_, v| v.notify? }.keys
      end

      def notifying_exceptions
        @@registered_exceptions.select { |_, v| v.notify? }.keys
      end

      def friendly_message(proxy)
        options_for(proxy.name).message ||
          friendly_status_messages[proxy.status] ||
            default_friendly_message
      end

      def notifies_for?(exception_name)
        notifying_exceptions.include?(exception_name)
      end

      def status(exception_name)
        @@registered_exceptions[exception_name].status_code
      end

      def http_code(status)
        Rack::Utils.status_code(status)
      end

      def extras_proc(exception_name)
        @@registered_exceptions[exception_name].extras
      end

      def generate_id
        sprintf "%06d", "#{SecureRandom.random_number(10**6)}"
      end

      def configure
        yield configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end

      private
      def options_for(name)
        @@registered_exceptions[name]
      end

      def friendly_status_messages
        @@friendly_status_messages ||= {
          internal_server_error: default_friendly_message,
          :not_found => 'We could not find the requested information.',
          bad_request: 'The request was unrecognized.',
          forbidden: 'You are not allowed to do that.',
          unprocessable_entity: 'Your browser asked for something that we cannot do.'
        }
      end

      def default_friendly_message
        "Sorry, #{configuration.app_name} had some unexpected trouble with your request."
      end

      def resolve_ip(ip)
        Resolv.getname(ip) rescue 'unknown'
      end

      def log_system_error(proxy)
        if notifies_for?(proxy.name)
          logger = Logger.new(proxy)
          logger.record_system_error!
        end
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
          listener.openstax_exception_rescued(proxy, notifies_for?(proxy.name))
        end
      end
    end
  end
end
