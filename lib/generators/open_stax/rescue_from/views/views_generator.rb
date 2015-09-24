require 'rails/generators'

module OpenStax
  module RescueFrom
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../../../app/views", __FILE__)

      def copy_views
        copy_file "errors/any.html.erb", "app/views/errors/any.html.erb"
      end
    end
  end
end
