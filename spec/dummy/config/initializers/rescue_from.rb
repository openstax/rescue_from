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
end
