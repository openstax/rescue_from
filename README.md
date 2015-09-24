# RescueFrom

This is the gem that brings together disparate systems within OpenStax and abstracts consistent exception rescuing with html and json responses, and email notifying

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rescue_from', '~> 1.0.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rescue_from

## Usage

Run the install generator to get the config initializer, the error template, and the configured middleware per environment

```
$ rails g open_stax:rescue_from:install
```

Declare that you want to use the openstax exception rescuer in your controller, preferably your `ApplicationController`

```ruby
class ApplicationController < ActionController::Base

  # ...

  use_openstax_exception_rescue

  # ...

  # Override the before and after hooks if you want to
  # (See 'Controller before/after hooks')
  #
  # private
  # def before_openstax_exception_rescue(exception_proxy)
  #   # noop
  # end
  #
  # def after_openstax_exception_rescue(exception_proxy)
  #   respond_to do |f|
  #     f.xml { render text: "I respond strangely to the XML format!",
  #                    status: exception_proxy.status }
  #   end
  # end
end
```

## Configuration

This configuration, which is placed in `./config/initializers/openstax_rescue_from.rb` by the install generator, shows the defaults:

```ruby
OpenStax::RescueFrom.configure do |config|
  config.raise_exceptions = ENV['RAISE_EXCEPTIONS'] ||
                              Rails.application.config.consider_all_requests_local

  config.app_name = ENV['APP_NAME'] || 'Tutor'
  config.app_env = ENV['APP_ENV'] || 'DEV'

  config.logger = Rails.logger
  config.notifier = ExceptionNotifier

  config.html_error_template_path = 'errors/any'
  config.html_error_template_layout_name = 'application'

  config.email_prefix = "[#{app_name}] (#{app_env}) "
  config.sender_address = ENV['EXCEPTION_SENDER'] ||
                            %{"OpenStax Tutor" <noreply@openstax.org>}
  config.exception_recipients = ENV['EXCEPTION_RECIPIENTS'] ||
                                  %w{tutor-notifications@openstax.org}

  # Of course, you can append to the following lists and maps:

  # config.exception_status_codes['ArgumentError'] = :unprocessable_entity
  # config.friendly_status_messages[:bad_request] = 'Your request was not good.'
  # config.non_notifying_exceptions += ['ArgumentError']
  # config.exception_extras['ArgumentError'] = ->(exception) {
  #   { headers: exception.response.headers,
  #     status: exception.response.status,
  #     body: exception.response.body }
  # }
end
```

## Exceptions lists and status code maps

See `OpenStax::RescueFrom::Configuration`

https://github.com/openstax/rescue_from/blob/master/lib/openstax/rescue_from/configuration.rb#L17

## Controller before/after hooks
```ruby
#
# Mixed in Controller module instance methods
#

def before_openstax_exception_rescue(exception_proxy)
  @message = exception_proxy.friendly_message
  @status = exception_proxy.status
  @error_id = exception_proxy.error_id
end

def after_openstax_exception_rescue(exception_proxy)
  respond_to do |f|
    f.html { render template: config.html_error_template_path, layout: config.html_error_template_layout_name, status: exception_proxy.status }
    f.json { render json: { error_id: exception_proxy.error_id }, status: exception_proxy.status }
    f.all { render nothing: true, status: exception_proxy.status }
  end
end

# Just override these methods in your own controller if you wish
```

## HTTP Status Codes

See `OpenStax::RescueFrom::Configuration`

https://github.com/openstax/rescue_from/blob/master/lib/openstax/rescue_from/configuration.rb#L17

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/openstax/rescue_from.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

