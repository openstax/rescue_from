require 'exception_notification'

module OpenStax
  module RescueFrom
    class Configuration

      attr_accessor :raise_exceptions, :logger, :notifier, :html_error_template_path,
        :html_error_template_layout_name, :app_name, :app_env, :exception_status_codes,
        :non_notifying_exceptions, :exception_extras, :friendly_status_messages,
        :email_prefix, :sender_address, :exception_recipients

      def initialize
        @raise_exceptions = ENV['RAISE_EXCEPTIONS'] || false

        @app_name = ENV['APP_NAME'] || 'Tutor'
        @app_env = ENV['APP_ENV'] || 'DEV'

        @logger = Rails.logger
        @notifier = ExceptionNotifier

        @html_error_template_path = 'errors/any'
        @html_error_template_layout_name = 'application'

        @email_prefix = "[#{app_name}] (#{app_env}) "
        @sender_address = ENV['EXCEPTION_SENDER'] ||
                            %{"OpenStax Tutor" <noreply@openstax.org>}
        @exception_recipients = ENV['EXCEPTION_RECIPIENTS'] ||
                                   %w{tutor-notifications@openstax.org}

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
          internal_server_error: "Sorry, #{app_name} had some unexpected trouble with your request."
        }
      end
    end
  end
end
