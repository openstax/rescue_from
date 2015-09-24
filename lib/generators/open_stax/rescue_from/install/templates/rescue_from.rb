require 'rescue_from'

OpenStax::RescueFrom.configure do |config|
  config.raise_exceptions = Rails.application.config.consider_all_requests_local

  # config.application_name = 'Tutor'

  # config.logger = Rails.logger

  # config.notifier = ExceptionNotifier

  # config.html_template_path = 'errors/any'

  # config.layout_name = 'application'

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
