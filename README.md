# RescueFrom

This is the gem that brings together disparate systems within OpenStax and abstracts consistent exception rescuing with html and json responses, and email notifying

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rescue_from', '~> 1.1.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rescue_from

## Usage

Run the install generator to get the config initializer

```
$ rails g open_stax:rescue_from:install
```

Declare that you want to use the openstax exception rescuer in your controller, preferably your `ApplicationController`

```ruby
class ApplicationController < ActionController::Base

  # ...

  use_openstax_exception_rescue

  # ...

  # Override the rescued hook which is called when configuration.raise_exceptions is false
  # (See 'Controller hook')
  #
  # def openstax_exception_rescued(exception_proxy)
  #   app_name = openstax_rescue_config.app_name
  #     # RescueFrom.configuration private method available to you
  #
  #   respond_to do |f|
  #     f.xml { render text: "I respond strangely to the XML format!",
  #                    status: exception_proxy.status }
  #   end
  # end
end
```

## Configuration

This configuration, which is placed in `./config/initializers/rescue_from.rb` by the install generator, shows the defaults:

```ruby
OpenStax::RescueFrom.configure do |config|
  config.raise_exceptions = ![false, 'false'].include?(ENV['RAISE_EXCEPTIONS']) ||
                              Rails.application.config.consider_all_requests_local

  config.app_name = ENV['APP_NAME']
  config.app_env = ENV['APP_ENV']
  config.contact_name = ENV['EXCEPTION_CONTACT_NAME']
    # can be a name, or a web/email address. See 'View helper' below

  config.notifier = ExceptionNotifier

  config.html_error_template_path = 'errors/any'
  config.html_error_template_layout_name = 'application'

  config.email_prefix = "[#{app_name}] (#{app_env}) "
  config.sender_address = ENV['EXCEPTION_SENDER']
  config.exception_recipients = ENV['EXCEPTION_RECIPIENTS']
end
```

## Registering exceptions

In `./config/initializers/rescue_from.rb` it is recommended you register your exceptions

Note that any unregistered exceptions rescued during run-time will be registered with the default options. See below.

```ruby
require 'openstax_rescue_from'

OpenStax::RescueFrom.configure do |c|
  # c.app_name ...
end

# OpenStax::RescueFrom#register_exception default options:
#
# { notify: true,
#   status: :internal_server_error,
#   extras: ->(exception) { {} } }
#
# Any unregistered exceptions rescued during run-time
# will be registered during rescue with the options above

OpenStax::RescueFrom.register_exception('SecurityTransgression',
                                        notify: false,
                                        status: :forbidden)

OpenStax::RescueFrom.register_exception(ActiveRecord::NotFound,
                                        notify: false,
                                        status: :not_found)

OpenStax::RescueFrom.register_exception('OAuth2::Error',
                                        extras: ->(exception) {
                                          { headers: exception.response.headers,
                                            status: exception.response.status,
                                            body: exception.response.body }
                                        })

OpenStax::RescueFrom.translate_status_codes({
  forbidden: 'You are not allowed to access this.',
  not_found: 'We couldn't find what you asked for.',
})
#
# Default:
#   internal_server_error: "Sorry, #{OpenStax::RescueFrom.configuration.app_name} had some unexpected trouble with your request."
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

def openstax_exception_rescued(exception_proxy)
  @message = exception_proxy.friendly_message
  @status = exception_proxy.status
  @error_id = exception_proxy.error_id

  respond_to do |f|
    f.html { render template: openstax_rescue_config.html_error_template_path,
                    layout: openstax_rescue_config.html_error_template_layout_name,
                    status: exception_proxy.status }
    f.json { render json: { error_id: exception_proxy.error_id }
                    status: exception_proxy.status }
    f.all { render nothing: true, status: exception_proxy.status }
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
