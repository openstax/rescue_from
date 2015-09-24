module OpenStax
  module RescueFrom
    module Controller
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def use_openstax_exception_rescue
          rescue_from Exception, with: :openstax_exception_rescue
        end
      end

      private
      def openstax_exception_rescue(exception)
        proxy = ExceptionProxy.new(exception)

        before_openstax_exception_rescue(proxy)
        log_system_error(proxy)
        send_notifying_exceptions(proxy)
        finish_exception_rescue(proxy)
      end

      def before_openstax_exception_rescue(proxy)
        @message = proxy.friendly_message
        @code = proxy.status_code
        @error_id = proxy.error_id
      end

      def log_system_error(proxy)
        logger = Logger.new(proxy)
        logger.record_system_error!
      end

      def send_notifying_exceptions(proxy)
        if proxy.notify?
          openstax_rescue_config.notifier.notify_exception(
            proxy.exception,
            env: request.env,
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

      def finish_exception_rescue(proxy)
        if openstax_rescue_config.raise_exceptions
          raise proxy.exception
        else
          after_openstax_exception_rescue(proxy)
        end
      end

      def after_openstax_exception_rescue(proxy)
        respond_to do |f|
          f.html { render template: openstax_rescue_config.html_template_path,
                          layout: openstax_rescue_config.layout_name,
                          status: proxy.status }

          f.json { render json: { error_id: proxy.error_id }, status: proxy.status }

          f.all { render nothing: true, status: proxy.status }
        end
      end

      def openstax_rescue_config
        RescueFrom.configuration
      end
    end
  end
end
