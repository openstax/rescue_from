require 'rails/generators'

module OpenStax
  module RescueFrom
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_initializer
        copy_file "rescue_from.rb", "config/initializers/rescue_from.rb"
      end

      def configure_environments
        test_file = "test.rb"
        test_middleware = <<-TEST
  config.middleware.use ExceptionNotification::Rack, email: {
    email_prefix: "[Tutor] (TEST) ",
    sender_address: %{"OpenStax Tutor" <noreply@openstax.org>},
    exception_recipients: %w{tutor-notifications@openstax.org}
  }
TEST
        dev_file = "development.rb"
        dev_middleware = <<-DEV
  config.middleware.use ExceptionNotification::Rack, email: {
    email_prefix: "[Tutor] (DEV) ",
    sender_address: %{"OpenStax Tutor" <noreply@openstax.org>},
    exception_recipients: %w{tutor-notifications@openstax.org}
  }
DEV
        prod_file = "production.rb"
        prod_middleware = <<-PROD
  config.middleware.use ExceptionNotification::Rack, :email => {
    email_prefix: "[Tutor] (\#{OpenStax::RescueFrom::DeployUtils.server_nickname}) ",
    sender_address: %{"OpenStax Tutor" <noreply@openstax.org>},
    exception_recipients: %w{tutor-notifications@openstax.org}
  }
PROD

        base = "config/environments/"
        original_test = File.binread("#{base}#{test_file}")
        original_dev = File.binread("#{base}#{dev_file}")
        original_prod = File.binread("#{base}#{prod_file}")
        sentinel = "Rails.application.configure do\n"

        unless original_test.include?('config.middleware.use ExceptionNotification::Rack')
          inject_into_file "#{base}#{test_file}", test_middleware, after: sentinel
        end

        unless original_dev.include?('config.middleware.use ExceptionNotification::Rack')
          inject_into_file "#{base}#{dev_file}", dev_middleware, after: sentinel
        end

        unless original_prod.include?('config.middleware.use ExceptionNotification::Rack')
          inject_into_file "#{base}#{prod_file}", prod_middleware, after: sentinel
        end
      end
    end
  end
end
