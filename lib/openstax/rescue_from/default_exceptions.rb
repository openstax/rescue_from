module OpenStax
  module RescueFrom
    class DefaultExceptions
      def self.pre_register!
        RescueFrom.register_exception(ActiveRecord::RecordNotFound,
                                      notify: false,
                                      status: :not_found)

        RescueFrom.register_exception(ActionController::RoutingError,
                                      notify: false,
                                      status: :not_found)

        RescueFrom.register_exception(ActionController::UnknownController,
                                      notify: false,
                                      status: :not_found)

        RescueFrom.register_exception(ActionController::InvalidAuthenticityToken,
                                      notify: false,
                                      status: :unprocessable_entity)

        RescueFrom.register_exception(AbstractController::ActionNotFound,
                                      notify: false,
                                      status: :not_found)

        RescueFrom.register_exception(ActionView::MissingTemplate,
                                      notify: false,
                                      status: :bad_request)
      end
    end
  end
end
