module OpenStax
  module RescueFrom
    module Controller
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def use_openstax_exception_rescue
          rescue_from Exception, with: :openstax_exception_rescue
        end
      end

      def openstax_exception_rescue(exception)
        wrapped = WrappedException.new(exception: exception, listener: self)
        wrapped.rescue_exception!
      end

      def before_openstax_exception_rescue(wrapped)
        @message = wrapped.friendly_message
        @code = wrapped.status_code
        @error_id = wrapped.error_id
      end

      def after_openstax_exception_rescue(wrapped)
        respond_to do |f|
          f.html { render template: openstax_rescue_config.html_template_path,
                          layout: openstax_rescue_config.layout_name,
                          status: wrapped.status }

          f.json { render json: { error_id: wrapped.error_id }, status: wrapped.status }

          f.all { render nothing: true, status: wrapped.status }
        end
      end

      private
      def openstax_rescue_config
        RescueFrom.configuration
      end
    end
  end
end
