module OpenStax
  module RescueFrom
    module Controller
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def openstax_exception_rescue
          rescue_from Exception, with: :rescue_from_openstax_exception
        end
      end

      def rescue_from_openstax_exception(exception)
        wrapped_exception = WrappedException.new(exception: exception, listener: self)
        @message = wrapped_exception.friendly_message
        @code = wrapped_exception.status_code
        @error_id = wrapped_exception.error_id
        wrapped_exception.handle_exception!
      end
    end
  end
end
