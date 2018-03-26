module OpenStax
  module RescueFrom
    class DefaultExceptions
      def self.pre_register!
        RescueFrom.register_exception(SystemExit,
                                      notify: false,
                                      status: :service_unavailable)

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

        RescueFrom.register_exception(ActionController::UnknownHttpMethod,
                                      notify: false,
                                      status: :bad_request)

        RescueFrom.register_exception(ActionController::ParameterMissing,
                                      notify: false,
                                      status: :bad_request)

        RescueFrom.register_exception('SecurityTransgression',
                                      notify: false,
                                      status: :forbidden)

        RescueFrom.register_exception('OAuth2::Error',
                                      extras: ->(ex) {
                                        { headers: ex.response.headers,
                                          status: ex.response.status,
                                          body: ex.response.body }
                                      })

        RescueFrom.register_exception('Apipie::ParamMissing',
                                      notify: false,
                                      status: :unprocessable_entity)
      end
    end
  end
end
