require_relative '../../../support/exceptions_list'
require 'openstax_rescue_from'
require 'exception_notification'

OpenStax::RescueFrom.configure do |config|
  config.raise_exceptions = false

  config.app_name = 'RescueFrom Dummy App'
  config.contact_name = 'RescueFromDummy.com'

  config.notify_proc = ->(proxy, controller) do
    ExceptionNotifier.notify_exception(
      proxy.exception,
      env: controller.request.env,
      data: {
        error_id: proxy.error_id,
        class: proxy.name,
        message: proxy.message,
        first_line_of_backtrace: proxy.first_backtrace_line,
        cause: proxy.cause,
        dns_name: resolve_ip(controller.request.remote_ip),
        extras: proxy.extras
      },
      sections: %w(data request session environment backtrace)
    )
  end
  config.notify_background_proc = ->(proxy) do
    ExceptionNotifier.notify_exception(
      proxy.exception,
      data: {
        error_id: proxy.error_id,
        class: proxy.name,
        message: proxy.message,
        first_line_of_backtrace: proxy.first_backtrace_line,
        cause: proxy.cause,
        extras: proxy.extras
      },
      sections: %w(data environment backtrace)
    )
  end
  config.notify_rack_middleware = ExceptionNotification::Rack
  config.notify_rack_middleware_options = {
    email: {
      email_prefix: "[#{config.app_name}] (DUM) ",
      sender_address: 'donotreply@dummyapp.com',
      exception_recipients: 'notify@dummyapp.com'
    }
  }
  # URL generation errors are caused by bad routes, for example, and should not be ignored
  ExceptionNotifier.ignored_exceptions.delete("ActionController::UrlGenerationError")

  # config.html_error_template_path = 'errors/any'
  # config.html_error_template_layout_name = 'application'
end

# Exceptions in controllers might be reraised or not depending on the settings above
ActionController::Base.use_openstax_exception_rescue

# RescueFrom always reraises background exceptions so that the background job may properly fail
ActiveJob::Base.use_openstax_exception_rescue

OpenStax::RescueFrom.translate_status_codes({
  forbidden: "You are not allowed to access this.",
  not_found: "We couldn't find what you asked for.",
  internal_server_error: "Sorry, #{OpenStax::RescueFrom.configuration.app_name} had some unexpected trouble with your request."
})
