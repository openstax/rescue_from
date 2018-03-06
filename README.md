# RescueFrom

[![Gem Version](https://badge.fury.io/rb/openstax_rescue_from.svg)](http://badge.fury.io/rb/openstax_rescue_from)
[![Build Status](https://travis-ci.org/openstax/rescue_from.svg?branch=master)](https://travis-ci.org/openstax/rescue_from)
[![Code Climate](https://codeclimate.com/github/openstax/rescue_from/badges/gpa.svg)](https://codeclimate.com/github/openstax/rescue_from)

This is the gem that brings together disparate systems within OpenStax and abstracts consistent exception rescuing with html and json responses, and email notifying

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rescue_from'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rescue_from

## Usage

Run the install generator to get the config initializer

```
$ rails g openstax:rescue_from:install
```

You can override the controller action that renders the error templates:

```ruby
class ApplicationController < ActionController::Base
  # Override the rescued hook which is called when configuration.raise_exceptions is false
  # (See 'Controller hook')
  #
  # def openstax_exception_rescued(exception_proxy, did_notify)
  #   app_name = openstax_rescue_config.app_name
  #     # RescueFrom.configuration private method available to you
  #
  #   respond_to do |f|
  #     f.xml { render plain: "I respond strangely to the XML format!",
  #                    status: exception_proxy.status }
  #   end
  # end
end
```

## Registering Exceptions

```ruby
# Use OpenStax::RescueFrom.register_exception(exception_constant_or_string, options = {})
# to register new exceptions or override the options of existing ones

OpenStax::RescueFrom.register_exception(SecurityTransgression, status: 403,
                                                               extras: -> (exception) {
                                                                 { headers: exception.response.headers }
                                                               })

OpenStax::RescueFrom.register_exception('ActiveRecord::RecordNotFound', notify: false,
                                                                        status: 404)

# Use OpenStax::RescueFrom.register_unrecognized_exception(exception_constant_or_string, options = {})
# to register ONLY unrecognized exceptions, to avoid accidental overwriting of options

OpenStax::RescueFrom.register_unrecognized_exception(SecurityTransgression)

# when used with example above, the above example's options will prevail

# Default options:
#
# { notify: true,
#   status: :internal_server_error,
#   extras: ->(exception) { {} } }
```

**Note:** If you want to define `extras`, you **must** use a function that accepts `exception` as its argument

## Configuration

This configuration, which is placed in `./config/initializers/rescue_from.rb` by the install generator, shows the defaults:

```ruby
OpenStax::RescueFrom.configure do |config|
  config.raise_exceptions = ![false, 'false'].include?(ENV['RAISE_EXCEPTIONS']) ||
                              Rails.application.config.consider_all_requests_local

  config.app_name = ENV['APP_NAME']
  config.app_env = ENV['APP_ENV']
  # Can be a name, or a web/email address. See 'View helper' below
  config.contact_name = ENV['EXCEPTION_CONTACT_NAME']

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

  config.html_error_template_path = 'errors/any'
  config.html_error_template_layout_name = 'application'

  config.email_prefix = "[#{app_name}] (#{app_env}) "
  config.sender_address = ENV['EXCEPTION_SENDER']
  config.exception_recipients = ENV['EXCEPTION_RECIPIENTS']
end

# Exceptions in controllers might be reraised or not depending on the settings above
ActionController::Base.use_openstax_exception_rescue

# RescueFrom always reraises background exceptions so that the background job may properly fail
ActiveJob::Base.use_openstax_exception_rescue

# URL generation errors are caused by bad routes, for example, and should not be ignored
ExceptionNotifier.ignored_exceptions.delete("ActionController::UrlGenerationError")
```

## Controller hook
```ruby
#
#             -- Mixed in Controller module instance method --
#
#       -- this method is ONLY called when Exceptions are not raised --
#
# -- check your OpenStax::RescueFrom.configuration.raise_exceptions setting --
#
# Params:
#   exception_proxy - an OpenStax::RescueFrom::ExceptionProxy wrapper around
#     the exception
#   did_notify - true if the exception was sent out to notification channels
#     such as email or the log file
#

def openstax_exception_rescued(exception_proxy, did_notify)
  @message = exception_proxy.friendly_message
  @status = exception_proxy.status
  @error_id = exception_proxy.error_id
  @did_notify = did_notify

  respond_to do |f|
    f.html { render template: openstax_rescue_config.html_error_template_path,
                    layout: openstax_rescue_config.html_error_template_layout_name,
                    status: exception_proxy.status }
    f.json { render json: { error_id: exception_proxy.error_id }
                    status: exception_proxy.status }
    f.all { head exception_proxy.status }
  end
end

# Just override this method in your own controller if you wish
```

You will readily note that for HTML response, there is an error template rendered from within the gem. See below for overriding these default views.

## Override the views

You can either declare your own template path variables:

```ruby
OpenStax::RescueFrom.configure do |config|
  config.html_error_template_path = 'my/path'
  config.html_error_template_layout_name = 'my_layout'
end
```

or, you can generate the views into the default path:

```
$ rails g open_stax:rescue_from:views
```

## View helper

The gem provides an `openstax_rescue_from_contact_info` view helper that uses `OpenStax::RescueFrom.configuration.contact_name` to provide either just the name, or to link web and email addresses automatically for you.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/openstax/rescue_from.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
