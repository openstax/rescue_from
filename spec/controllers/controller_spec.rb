require 'rails_helper'
require './spec/support/exceptions_list'
require './spec/support/test_controller'

module Test
  RSpec.describe TestController do
    it 'intercepts OpenStax::RescueFrom::Exceptions::NON_NOTIFYING' do
      OpenStax::RescueFrom::Exceptions::NON_NOTIFYING.each do |ex|
        get :bad_action, exception: ex

        expected_status = OpenStax::RescueFrom::Exceptions::STATUS_MAP[ex]

        expect(response).to render_template('errors/any')
        expect(response).to have_http_status(expected_status),
          "expected #{expected_status}, got #{response.status} - for #{ex}"
      end
    end

    it 'intercepts these non notifying exceptions for json requests' do
      allow(SecureRandom).to receive(:random_number) { 123 }

      OpenStax::RescueFrom::Exceptions::NON_NOTIFYING.each do |ex|
        get :bad_action, exception: ex, format: :json

        expected_status = OpenStax::RescueFrom::Exceptions::STATUS_MAP[ex]

        expect(JSON.parse(response.body)).to eq({ 'error_id' => '%06d123' })
        expect(response).to have_http_status(expected_status),
          "expected #{expected_status}, got #{response.status} - for #{ex}"
      end
    end

    it 'intercepts non notifying exception for other formats with just the status' do
      formats = [:xsl, :php, :doc, :pdf, :csv, :xml]

      OpenStax::RescueFrom::Exceptions::NON_NOTIFYING.each do |ex|
        get :bad_action, exception: ex, format: formats.sample

        expected_status = OpenStax::RescueFrom::Exceptions::STATUS_MAP[ex]

        expect(response.body).to be_blank
        expect(response).to have_http_status(expected_status),
          "expected #{expected_status}, got #{response.status} - for #{ex}"
      end
    end
  end
end
