module OpenStax
  module RescueFrom
    module BackgroundJob
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def use_openstax_exception_rescue
          rescue_from Exception do |exception|
            RescueFrom.perform_background_rescue(exception)
          end
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_job) do
  ActiveJob::Base.send :include, OpenStax::RescueFrom::BackgroundJob
end
