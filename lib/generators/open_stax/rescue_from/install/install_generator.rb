require 'rails/generators'

module OpenStax
  module RescueFrom
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_initializer
        copy_file "rescue_from.rb", "config/initializers/rescue_from.rb"
      end
    end
  end
end
