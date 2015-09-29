require 'rails_helper'

RSpec.describe OpenStax::RescueFrom do
  it 'pre-registers a handful of exceptions' do
    exceptions = OpenStax::RescueFrom.registered_exceptions

    active_record_not_found = exceptions['ActiveRecord::RecordNotFound']
    expect(active_record_not_found).not_to be_notify
    expect(active_record_not_found.status_code).to be(:not_found)
    expect(active_record_not_found.extras.call(nil)).to eq({})

    action_controller_routing = exceptions['ActionController::RoutingError']
    expect(action_controller_routing).not_to be_notify
    expect(action_controller_routing.status_code).to be(:not_found)
    expect(action_controller_routing.extras.call(nil)).to eq({})

    action_controller_unknown = exceptions['ActionController::UnknownController']
    expect(action_controller_unknown).not_to be_notify
    expect(action_controller_unknown.status_code).to be(:not_found)
    expect(action_controller_unknown.extras.call(nil)).to eq({})

    controller_invalid_token = exceptions['ActionController::InvalidAuthenticityToken']
    expect(controller_invalid_token).not_to be_notify
    expect(controller_invalid_token.status_code).to be(:unprocessable_entity)
    expect(controller_invalid_token.extras.call(nil)).to eq({})

    controller_action_not_found = exceptions['AbstractController::ActionNotFound']
    expect(controller_action_not_found).not_to be_notify
    expect(controller_action_not_found.status_code).to be(:not_found)
    expect(controller_action_not_found.extras.call(nil)).to eq({})

    missing_template = exceptions['ActionView::MissingTemplate']
    expect(missing_template).not_to be_notify
    expect(missing_template.status_code).to be(:bad_request)
    expect(missing_template.extras.call(nil)).to eq({})
  end
end