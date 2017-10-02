module OpenStax
  module RescueFrom
    module Controller
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def use_openstax_exception_rescue
          rescue_from Exception do |exception|
            RescueFrom.perform_rescue(exception, self)
          end
        end
      end

      def openstax_exception_rescued(proxy, did_notify)
        @message = proxy.friendly_message
        @code = proxy.status_code
        @error_id = proxy.error_id
        @sorry = proxy.sorry
        @did_notify = did_notify

        respond_to do |f|
          f.html { render template: openstax_rescue_config.html_error_template_path,
                          layout: openstax_rescue_config.html_error_template_layout_name,
                          status: proxy.status }

          f.json { render json: { error_id: did_notify ? proxy.error_id : nil },
                          status: proxy.status }

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
