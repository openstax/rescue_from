require_relative '../../../support/exceptions_list'
require 'openstax_rescue_from'

OpenStax::RescueFrom.configure do |config|
  config.raise_exceptions = false

  config.app_name = 'RescueFrom Dummy App'
  config.app_env = 'DUM'
  config.contact_name = 'RescueFromDummy.com'

  # config.notifier = ExceptionNotifier

  # config.html_error_template_path = 'errors/any'
  # config.html_error_template_layout_name = 'application'

  # config.email_prefix = "[#{app_name}] (#{app_env}) "
  config.sender_address = 'donotreply@dummyapp.com'
  config.exception_recipients = 'notify@dummyapp.com'
end

OpenStax::RescueFrom.register_exception(SecurityTransgression,
                                        notify: false,
                                        status: :forbidden)

OpenStax::RescueFrom.register_exception(ActiveRecord::RecordNotFound,
                                        notify: false,
                                        status: :not_found)

OpenStax::RescueFrom.register_exception(OAuth2::Error,
                                        notify: true,
                                        extras: ->(exception) { 'found extras' })

OpenStax::RescueFrom.translate_status_codes({
  forbidden: "You are not allowed to access this.",
  :not_found => "We couldn't find what you asked for.",
  internal_server_error: "Sorry, #{OpenStax::RescueFrom.configuration.app_name} had some unexpected trouble with your request."
})
