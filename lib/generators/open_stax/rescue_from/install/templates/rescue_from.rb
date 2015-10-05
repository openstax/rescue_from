require 'openstax_rescue_from'

OpenStax::RescueFrom.configure do |config|
  config.raise_exceptions = ![false, 'false'].include?(ENV['RAISE_EXCEPTIONS']) ||
                              Rails.application.config.consider_all_requests_local

  # config.app_name = ENV['APP_NAME']
  # config.app_env = ENV['APP_ENV']
  # config.contact_name = ENV['EXCEPTION_CONTACT_NAME']

  # config.notifier = ExceptionNotifier

  # config.html_error_template_path = 'errors/any'
  # config.html_error_template_layout_name = 'application'

  # config.email_prefix = "[#{app_name}] (#{app_env}) "
  # config.sender_address = ENV['EXCEPTION_SENDER']
  # config.exception_recipients = ENV['EXCEPTION_RECIPIENTS']
end

# OpenStax::RescueFrom#register_exception default options:
#
# { notify: true,
#   status: :internal_server_error,
#   extras: ->(exception) { {} } }
#
# NOTE: Any unregistered exceptions rescued during run-time
# will be registered with RescueFrom with the above options

# OpenStax::RescueFrom.register_exception('SecurityTransgression',
#                                         notify: false,
#                                         status: :forbidden)
#
# OpenStax::RescueFrom.register_exception(ActiveRecord::NotFound,
#                                         notify: false,
#                                         status: :not_found)
#
# OpenStax::RescueFrom.register_exception('OAuth2::Error',
#                                         notify: true,
#                                         extras: ->(exception) {
#                                           { headers: exception.response.headers,
#                                             status: exception.response.status,
#                                             body: exception.response.body }
#
# OpenStax::RescueFrom.translate_status_codes({
#   forbidden: "You are not allowed to access this.",
#   :not_found => "We couldn't find what you asked for.",
# })
#
# Default:
#   - internal_server_error: "Sorry, #{OpenStax::RescueFrom.configuration.app_name} had some unexpected trouble with your request."
#   - not_found: 'Sorry, we could not find that resource.',
#   - bad_request: 'The request was unrecognized.',
#   - forbidden: 'You are not allowed to do that.'
#   - unprocessable_entity: 'The entity could not be processed.'
