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

Just declare the openstax exception rescuer in your controller, preferably your `ApplicationController`

```ruby
class ApplicationController < ActionController::Base
  # ...

  openstax_exception_rescue

  # ...
end
```

## How it works

OpenStax::RescueFrom uses a `WrappedException` around the rescued exception for convenient access to information such as: `name`, `header`, `status`, `message`, and `error_id`

From there, an `OpenStax::RescueFrom::Logger` is used to write customized entries to the configured `system_logger` and to do recursive logging for exceptions with causes

`WrappedException` requires an Exception, and a Listener. The listener should be an instance of `ActionController::Base`, unless of course the developer can provide a listener that can handle a `#respond_to` block and `#render` method similar to `ActionController::Base`, but this is currently not configurable anyway.

## Configuration

This configuration, which you should place in `./config/initializers/openstax_rescue_from.rb` shows the defaults

```ruby
OpenStax::RescueFrom.configure do |config|
  config.raise_exceptions = false          # Rails users may wish to use Rails.application.config.consider_all_requests_local to decide this
  config.system_logger = Rails.logger      # Any logger that takes a string in an #error method will work
  config.html_template_path = 'errors/any' # The template path for the HTML response
  config.layout_name = 'application'       # The layout name for the HTML response
end
```

## HTML Response

Renders the `errors/any` template in `./app/views` in the `application` layout. Client must provide this. Install generator possibly coming soon to copy a stock one in.

Returns corresponding HTTP status code

## JSON Response

```json
{ "error_id" : "some_generated_error_id_for_log_reference" }
// with the corresponding HTTP status code
```

## All other formats

Renders a blank response body with the corresponding HTTP status code

## HTTP Status Codes

See `OpenStax::RescueFrom::WrappedException::STATUS_MAP`

Located as of this writing, https://github.com/openstax/rescue_from/blob/implement-exception-emails/lib/openstax/rescue_from/wrapped_exception.rb#L74

## TODO

1. Implement ExceptionNotifier mailer
2. Provide install generator to copy in default config initializer
3. Provide stock `errors/any` template in install generator

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/openstax/rescue_from.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

