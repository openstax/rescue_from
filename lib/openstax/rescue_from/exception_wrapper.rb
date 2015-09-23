require 'openstax/rescue_from/logger'
require 'openstax/rescue_from/error'

module OpenStax
  module RescueFrom
    class ExceptionWrapper
      attr_reader :exception, :listener, :logger

      def initialize(exception:, listener: nil, logger: Logger.new(wrapped: self))
        @exception = exception
        @listener = listener
        @logger = logger
      end

      def handle_exception!
        logger.record_system_error!

        if config.raise_exceptions
          raise exception
        else
          listener_response
        end
      end

      def header
        @header ||= cause.blank? ? 'An exception occurred' : 'Exception cause'
      end

      def name
        @name ||= exception.class.name
      end

      def error_id
        @error_id ||= Error.id
      end

      def message
        @message ||= exception.message
      end

      def extras
        @extras ||= if extras_proc = EXTRAS_MAP[exception.class.name]
                      extras_proc.call(exception)
                    end
      end

      def cause
        @cause ||= exception.cause
      end

      def backtrace
        @backtrace ||= if cause.blank?
                         exception.backtrace.join("\n")
                       else
                         exception.backtrace.first
                       end
      end

      def status
        @status ||= STATUS_MAP[exception.class.name]
      end

      NON_NOTIFYING = Set.new [
        'SecurityTransgression',
        'ActiveRecord::RecordNotFound',
        'ActionController::RoutingError',
        'ActionController::UnknownController',
        'AbstractController::ActionNotFound',
        'ActionController::InvalidAuthenticityToken',
        'Apipie::ParamMissing',
        'ActionView::MissingTemplate'
      ]

      STATUS_MAP = Hash.new(:internal_server_error).merge({
        'SecurityTransgression' => :forbidden,
        'ActiveRecord::RecordNotFound' => :not_found,
        'ActionController::RoutingError' => :not_found,
        'ActionController::UnknownController' => :not_found,
        'AbstractController::ActionNotFound' => :not_found,
        'ActionController::InvalidAuthenticityToken' => :unprocessable_entity,
        'Apipie::ParamMissing' => :unprocessable_entity,
        'ActionView::MissingTemplate' => :bad_request,
      })

      EXTRAS_MAP = {
        'OAuth2::Error' => ->(exception) do
          { headers: exception.response.headers,
            status: exception.response.status,
            body: exception.response.body }
        end
      }

      private
      def listener_response
        listener.respond_to do |f|
          f.html { listener.render template: config.html_template_path,
                                   layout: config.layout_name,
                                   status: status }

          f.json { listener.render json: { error_id: error_id },
                                   status: status }

          f.all { listener.render nothing: true,
                                  status: status }
        end
      end

      def config
        OpenStax::RescueFrom.configuration
      end
    end
  end
end
