module OpenStax
  module RescueFrom
    module Controller
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def use_openstax_exception_rescue
          rescue_from Exception do |exception|
            RescueFrom.perform_rescue(exception: exception, listener: self)
          end
        end
      end

      def before_openstax_exception_rescue(proxy)
        @message = proxy.friendly_message
        @code = proxy.status_code
        @error_id = proxy.error_id
      end

      def after_openstax_exception_rescue(proxy)
        respond_to do |f|
          f.html { render template: openstax_rescue_config.html_error_template_path,
                          layout: openstax_rescue_config.html_error_template_layout_name,
                          status: proxy.status }

          f.json { render json: { error_id: proxy.error_id }, status: proxy.status }

          f.all { render nothing: true, status: proxy.status }
        end
      end

      private
      def openstax_rescue_config
        RescueFrom.configuration
      end
    end
  end
end
