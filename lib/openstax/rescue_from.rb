require 'openstax/rescue_from/exception_options'
require 'openstax/rescue_from/controller'
require 'openstax/rescue_from/background_job'
require 'openstax/rescue_from/view_helpers'
require 'openstax/rescue_from/configuration'

module OpenStax
  module RescueFrom
    class << self
      def perform_rescue(exception, listener = MuteListener.new)
        proxy = ExceptionProxy.new(exception)
        log_system_error(proxy)
        send_notifying_exceptions(proxy, listener)
        finish_exception_rescue(proxy, listener)
      end

      def perform_background_rescue(exception, listener = MuteListener.new)
        proxy = ExceptionProxy.new(exception)
        log_background_system_error(proxy)
        send_notifying_background_exceptions(proxy)
        finish_background_exception_rescue(proxy, listener)
      end

      # Not threadsafe
      def do_not_reraise
        original = configuration.raise_exceptions
        original_background = configuration.raise_background_exceptions
        begin
          configuration.raise_exceptions = false
          configuration.raise_background_exceptions = false
          yield
        ensure
          configuration.raise_exceptions = original
          configuration.raise_background_exceptions = original_background
        end
      end

      def register_exception(exception, options = {})
        name = exception.is_a?(String) ? exception : exception.name
        options = ExceptionOptions.new(options)
        @@registered_exceptions ||= {}
        @@registered_exceptions[name] = options
      end

      # For rescuing from specific blocks of code: OpenStax::RescueFrom.this {...}
      def this(background = true)
        begin
          yield
        rescue Exception => ex
          background ? perform_background_rescue(ex) : perform_rescue(ex)
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
        options_for(exception_name).status_code
      end

      def sorry(exception_name)
        options_for(exception_name).sorry
      end

      def http_code(status)
        Rack::Utils.status_code(status)
      end

      def extras_proc(exception_name)
        options_for(exception_name).extras
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
        @@registered_exceptions[name] || ExceptionOptions.new
      end

      def friendly_status_messages
        @@friendly_status_messages ||= {
          internal_server_error: default_friendly_message,
          not_found: 'We could not find the requested information.',
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
        return unless notifies_for?(proxy.name)

        logger = Logger.new(proxy)
        logger.record_system_error!
      end

      def log_background_system_error(proxy)
        return unless notifies_for?(proxy.name)

        logger = Logger.new(proxy)
        logger.record_system_error!('A background job exception occurred')
      end

      def send_notifying_exceptions(proxy, controller)
        return if !configuration.notify_exceptions || !notifies_for?(proxy.name)

        instance_exec(proxy, controller, &configuration.notify_proc)
      end

      def send_notifying_background_exceptions(proxy)
        return if !configuration.notify_background_exceptions || !notifies_for?(proxy.name)

        instance_exec(proxy, &configuration.notify_background_proc)
      end

      def finish_exception_rescue(proxy, listener)
        if configuration.raise_exceptions
          raise proxy.exception
        else
          listener.openstax_exception_rescued(proxy, notifies_for?(proxy.name))
        end
      end

      def finish_background_exception_rescue(proxy, listener)
        if configuration.raise_background_exceptions
          raise proxy.exception
        else
          listener.openstax_exception_rescued(proxy, notifies_for?(proxy.name))
        end
      end
    end
  end
end
