module OpenStax
  module RescueFrom
    module Exceptions
      NON_NOTIFYING = Set.new [
        'SecurityTransgression',
        'ActiveRecord::RecordNotFound',
        'ActionController::RoutingError',
        'ActionController::UnknownController',
        'AbstractController::ActionNotFound',
        'ActionController::InvalidAuthenticityToken',
        'Apipie::ParamMissing',
        'ActionView::MissingTemplate'
      ]

      STATUS_MAP = Hash.new(:internal_server_error).merge({
        'SecurityTransgression' => :forbidden,
        'ActiveRecord::RecordNotFound' => :not_found,
        'ActionController::RoutingError' => :not_found,
        'ActionController::UnknownController' => :not_found,
        'AbstractController::ActionNotFound' => :not_found,
        'ActionController::InvalidAuthenticityToken' => :unprocessable_entity,
        'Apipie::ParamMissing' => :unprocessable_entity,
        'ActionView::MissingTemplate' => :bad_request,
      })

      EXTRAS_MAP = {
        'OAuth2::Error' => ->(exception) do
          { headers: exception.response.headers,
            status: exception.response.status,
            body: exception.response.body }
        end
      }
    end
  end
end
