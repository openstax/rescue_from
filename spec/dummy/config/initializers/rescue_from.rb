require 'openstax_rescue_from'

OpenStax::RescueFrom.configure do |config|
  config.raise_exceptions = ![false, 'false'].include?(ENV['RAISE_EXCEPTIONS'])

  # config.app_name = 'Tutor'
  # config.app_env = ENV['APP_ENV']

  # config.logger = Rails.logger
  # config.notifier = ExceptionNotifier

  # config.html_error_template_path = 'errors/any'
  # config.html_error_template_layout_name = 'application'

  # config.email_prefix = app_name.blank? ? "" : "[#{app_name}] (#{app_env}) "
  # config.sender_address = ENV['EXCEPTION_SENDER']
  # config.exception_recipients = ENV['EXCEPTION_RECIPIENTS']
end
