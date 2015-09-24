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

      def before_openstax_exception_rescue(wrapped)
        @message = wrapped.friendly_message
        @code = wrapped.status_code
        @error_id = wrapped.error_id
      end

      def after_openstax_exception_rescue(wrapped)
        respond_to do |f|
          f.html { render template: openstax_rescue_config.html_template_path,
                          layout: openstax_rescue_config.layout_name,
                          status: wrapped.status }

          f.json { render json: { error_id: wrapped.error_id }, status: wrapped.status }

          f.all { render nothing: true, status: wrapped.status }
        end
      end

      private
      def openstax_exception_rescue(exception)
        wrapped = WrappedException.new(exception)

        before_openstax_exception_rescue(wrapped)
        record_system_error(wrapped)
        send_notifying_exceptions(wrapped)
        finish_exception_rescue(wrapped)
      end

      def record_system_error(wrapped)
        logger = Logger.new(wrapped)
        logger.record_system_error!
      end

      def send_notifying_exceptions(wrapped)
        if wrapped.notify?
          openstax_rescue_config.notifier.notify_exception(
            wrapped.exception,
            env: request.env,
            data: {
              error_id: wrapped.error_id,
              :class => wrapped.name,
              message: wrapped.message,
              first_line_of_backtrace: wrapped.exception.backtrace.first,
              cause: wrapped.cause,
              dns_name: wrapped.dns_name,
              extras: wrapped.extras
            },
            sections: %w(data request session environment backtrace)
          )
        end
      end

      def finish_exception_rescue(wrapped)
        if openstax_rescue_config.raise_exceptions
          raise wrapped.exception
        else
          after_openstax_exception_rescue(wrapped)
        end
      end

      def openstax_rescue_config
        RescueFrom.configuration
      end
    end
  end
end
