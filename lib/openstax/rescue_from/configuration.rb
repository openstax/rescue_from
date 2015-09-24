module OpenStax
  module RescueFrom
    class Configuration

      attr_accessor :raise_exceptions, :logger, :notifier,
        :html_template_path, :layout_name, :application_name, :exception_status_codes,
        :non_notifying_exceptions, :exception_extras,:friendly_status_messages

      def initialize
        @raise_exceptions = false
        @application_name = 'Tutor'
        @logger = Rails.logger
        @notifier = ExceptionNotifier
        @html_template_path = 'errors/any'
        @layout_name = 'application'

        @exception_status_codes = Hash.new(:internal_server_error).merge({
          'SecurityTransgression' => :forbidden,
          'ActiveRecord::RecordNotFound' => :not_found,
          'ActionController::RoutingError' => :not_found,
          'ActionController::UnknownController' => :not_found,
          'AbstractController::ActionNotFound' => :not_found,
          'ActionController::InvalidAuthenticityToken' => :unprocessable_entity,
          'Apipie::ParamMissing' => :unprocessable_entity,
          'ActionView::MissingTemplate' => :bad_request,
        })

        @non_notifying_exceptions = [
          'SecurityTransgression',
          'ActiveRecord::RecordNotFound',
          'ActionController::RoutingError',
          'ActionController::UnknownController',
          'AbstractController::ActionNotFound',
          'ActionController::InvalidAuthenticityToken',
          'Apipie::ParamMissing',
          'ActionView::MissingTemplate'
        ]

        @exception_extras = {
          'OAuth2::Error' => ->(exception) do
            { headers: exception.response.headers,
              status: exception.response.status,
              body: exception.response.body }
          end
        }

        @friendly_status_messages = {
          forbidden: "You are not allowed to access this.",
          :not_found => "We couldn't find what you asked for.",
          unprocessable_entity: "We didn't understand what you asked for.",
          internal_server_error: "Sorry, #{application_name} had some unexpected trouble with your request."
        }
      end
    end
  end
end
