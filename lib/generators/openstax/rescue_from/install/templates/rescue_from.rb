require 'openstax_rescue_from'

OpenStax::RescueFrom.configure do |config|
  config.raise_exceptions = ![false, 'false'].include?(ENV['RAISE_EXCEPTIONS']) ||
                              Rails.application.config.consider_all_requests_local
  config.raise_background_exceptions = ![false, 'false'].include?(
    ENV['RAISE_BACKGROUND_EXCEPTIONS']
  )

  # config.app_name = ENV['APP_NAME']
  # config.app_env = ENV['APP_ENV']
  # config.contact_name = ENV['EXCEPTION_CONTACT_NAME']

  # To use ExceptionNotifier add `gem 'exception_notification'` to your Gemfile and then:
  # config.notify_proc = ->(proxy, controller) do
  #   ExceptionNotifier.notify_exception(
  #     proxy.exception,
  #     env: controller.request.env,
  #     data: {
  #       error_id: proxy.error_id,
  #       class: proxy.name,
  #       message: proxy.message,
  #       first_line_of_backtrace: proxy.first_backtrace_line,
  #       cause: proxy.cause,
  #       dns_name: resolve_ip(controller.request.remote_ip),
  #       extras: proxy.extras
  #     },
  #     sections: %w(data request session environment backtrace)
  #   )
  # end
  # config.notify_background_proc = ->(proxy) do
  #   ExceptionNotifier.notify_exception(
  #     proxy.exception,
  #     data: {
  #       error_id: proxy.error_id,
  #       class: proxy.name,
  #       message: proxy.message,
  #       first_line_of_backtrace: proxy.first_backtrace_line,
  #       cause: proxy.cause,
  #       extras: proxy.extras
  #     },
  #     sections: %w(data environment backtrace)
  #   )
  # end
  # config.notify_rack_middleware = ExceptionNotification::Rack,
  # config.notify_rack_middleware_options = {
  #   email: {
  #     email_prefix: RescueFrom.configuration.email_prefix,
  #     sender_address: RescueFrom.configuration.sender_address,
  #     exception_recipients: RescueFrom.configuration.exception_recipients
  #   }
  # }
  # URL generation errors are caused by bad routes, for example, and should not be ignored
  # ExceptionNotifier.ignored_exceptions.delete("ActionController::UrlGenerationError")

  # To use Raven (Sentry) add `gem 'sentry-raven', require: 'raven/base'` to your Gemfile and then:
  # config.notify_proc = -> do |proxy, controller|
  #   extra = {
  #     env: controller.request.env,
  #     error_id: proxy.error_id,
  #     class: proxy.name,
  #     message: proxy.message,
  #     first_line_of_backtrace: proxy.first_backtrace_line,
  #     cause: proxy.cause,
  #     dns_name: resolve_ip(controller.request.remote_ip)
  #   }
  #   extra.merge!(proxy.extras) if proxy.extras.is_a? Hash
  #
  #   Raven.capture_exception(proxy.exception, extra: extra)
  # end
  # config.notify_background_proc = -> do |proxy|
  #   extra = {
  #     error_id: proxy.error_id,
  #     class: proxy.name,
  #     message: proxy.message,
  #     first_line_of_backtrace: proxy.first_backtrace_line,
  #     cause: proxy.cause
  #   }
  #   extra.merge!(proxy.extras) if proxy.extras.is_a? Hash
  #
  #   Raven.capture_exception(proxy.exception, extra: extra)
  # end
  # require 'raven/integrations/rack'
  # config.notify_rack_middleware = Raven::Rack

  # config.html_error_template_path = 'errors/any'
  # config.html_error_template_layout_name = 'application'

  # config.email_prefix = "[#{app_name}] (#{app_env}) "
  # config.sender_address = ENV['EXCEPTION_SENDER']
  # config.exception_recipients = ENV['EXCEPTION_RECIPIENTS']
end

# Exceptions in controllers might be reraised or not depending on the settings above
ActionController::Base.use_openstax_exception_rescue

# RescueFrom always reraises background exceptions so that the background job may properly fail
ActiveJob::Base.use_openstax_exception_rescue

# OpenStax::RescueFrom.translate_status_codes(
#   internal_server_error: "Sorry, #{OpenStax::RescueFrom.configuration.app_name} had some unexpected trouble with your request.",
#   not_found: 'We could not find the requested information.',
#   bad_request: 'The request was unrecognized.',
#   forbidden: 'You are not allowed to do that.',
#   unprocessable_entity: 'Your browser asked for something that we cannot do.'
# )

# OpenStax::RescueFrom#register_exception default options:
# { notify: true, status: :internal_server_error, extras: ->(exception) { {} } }
#
# NOTE: Any unregistered exceptions rescued during run-time
# will be registered with RescueFrom with the above options
#
# Default exceptions:
#
# RescueFrom.register_exception(ActiveRecord::RecordNotFound,
#                               notify: false,
#                               status: :not_found)
#
# RescueFrom.register_exception(ActionController::RoutingError,
#                               notify: false,
#                               status: :not_found)
#
# RescueFrom.register_exception(ActionController::UnknownController,
#                               notify: false,
#                               status: :not_found)
#
# RescueFrom.register_exception(ActionController::InvalidAuthenticityToken,
#                               notify: false,
#                               status: :unprocessable_entity)
#
# RescueFrom.register_exception(AbstractController::ActionNotFound,
#                               notify: false,
#                               status: :not_found)
#
# RescueFrom.register_exception(ActionView::MissingTemplate,
#                               notify: false,
#                               status: :bad_request)
#
# RescueFrom.register_exception(ActionController::UnknownHttpMethod,
#                               notify: false,
#                               status: :bad_request)
#
# RescueFrom.register_exception(ActionController::ParameterMissing,
#                               notify: false,
#                               status: :bad_request)
#
# RescueFrom.register_exception('SecurityTransgression',
#                               notify: false,
#                               status: :forbidden)
#
# RescueFrom.register_exception('OAuth2::Error',
#                               extras: ->(ex) {
#                                 {
#                                   headers: ex.response.headers,
#                                   status: ex.response.status,
#                                   body: ex.response.body
#                                 }
#                               })
#
# RescueFrom.register_exception('Apipie::ParamMissing',
#                               notify: false,
#                               status: :unprocessable_entity)
