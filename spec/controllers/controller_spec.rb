require 'rails_helper'
require './spec/support/exceptions_list'
require './spec/support/test_controller'

module Test
  RSpec.describe TestController do
    it 'intercepts OpenStax::RescueFrom::Exceptions::NON_NOTIFYING' do
      OpenStax::RescueFrom::Exceptions::NON_NOTIFYING.each do |ex|
        get :bad_action, exception: ex

        expected_status = OpenStax::RescueFrom::Exceptions::STATUS_MAP[ex]

        expect(response).to have_http_status(expected_status),
          "expected #{expected_status}, got #{response.status} - for #{ex}"
        expect(response).to render_template('errors/any')
      end
    end
  end
end
