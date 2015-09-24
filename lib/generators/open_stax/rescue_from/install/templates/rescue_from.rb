require 'openstax_rescue_from'

OpenStax::RescueFrom.configure do |config|
  config.raise_exceptions = Rails.application.config.consider_all_requests_local

  # config.app_name = 'Tutor'
  # config.app_env = ENV['APP_ENV'] || 'DEV'

  # config.logger = Rails.logger
  # config.notifier = ExceptionNotifier

  # config.html_error_template_path = 'errors/any'
  # config.html_error_template_layout_name = 'application'

  # config.email_prefix = "[#{app_name}] (#{app_env}) "
  # config.sender_address = ENV['EXCEPTION_SENDER'] ||
  #                           %{"OpenStax Tutor" <noreply@openstax.org>}
  # config.exception_recipients = ENV['EXCEPTION_RECIPIENTS'] ||
  #                                 %w{tutor-notifications@openstax.org}

  # Append to the exception lists and maps
  #
  # config.exception_status_codes['ArgumentError'] = :unprocessable_entity
  # config.friendly_status_messages[:bad_request] = 'Your request was not good.'
  # config.non_notifying_exceptions += ['ArgumentError']
  # config.exception_extras['ArgumentError'] = ->(exception) {
  #   { headers: exception.response.headers,
  #     status: exception.response.status,
  #     body: exception.response.body }
  # }
end
