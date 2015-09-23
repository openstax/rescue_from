require 'rails_helper'
require './spec/support/exceptions_list'
require './spec/support/test_controller'

module Test
  RSpec.describe TestController do
    before do
      allow(SecureRandom).to receive(:random_number) { 123 }

      OpenStax::RescueFrom.configure do |c|
        c.raise_exceptions = false # default
      end
    end

    context 'configured to raise exceptions' do
      before do
        OpenStax::RescueFrom.configure do |c|
          c.raise_exceptions = true
        end
      end

      it 'raises the exceptions' do
        OpenStax::RescueFrom::WrappedException::NON_NOTIFYING.each do |ex|
          expect {
            get :bad_action, exception: ex
          }.to raise_error(ex.constantize)
        end
      end
    end

    (Set.new(['OAuth2::Error']) +
      OpenStax::RescueFrom::WrappedException::NON_NOTIFYING).each do |ex|
      it "logs the #{ex} exception" do
        allow(Rails.logger).to receive(:error)

        extras = if extras_proc = OpenStax::RescueFrom::WrappedException::EXTRAS_MAP[ex]
                   allow(extras_proc).to receive(:call) { 'found extras' }
                   'found extras'
                 else
                   nil
                 end

        allow_any_instance_of(ex.constantize).to receive(:message) { 'ex msg' }
        allow_any_instance_of(ex.constantize).to receive(:backtrace) { ['backtrace ln'] }

        get :bad_action, exception: ex

        expect(Rails.logger).to have_received(:error).with(
          "An exception occurred: #{ex} [%06d123] <ex msg> #{extras}\n\nbacktrace ln"
        )
      end
    end

    it 'intercepts OpenStax::RescueFrom::WrappedException::NON_NOTIFYING' do
      OpenStax::RescueFrom::WrappedException::NON_NOTIFYING.each do |ex|
        get :bad_action, exception: ex

        expected_status = OpenStax::RescueFrom::WrappedException::STATUS_MAP[ex]

        expect(response).to render_template('errors/any')
        expect(response).to have_http_status(expected_status),
          "expected #{expected_status}, got #{response.status} - for #{ex}"
      end
    end

    it 'intercepts these non notifying exceptions for json requests' do
      OpenStax::RescueFrom::WrappedException::NON_NOTIFYING.each do |ex|
        get :bad_action, exception: ex, format: :json

        expected_status = OpenStax::RescueFrom::WrappedException::STATUS_MAP[ex]

        expect(JSON.parse(response.body)).to eq({ 'error_id' => '%06d123' })
        expect(response).to have_http_status(expected_status),
          "expected #{expected_status}, got #{response.status} - for #{ex}"
      end
    end

    it 'intercepts non notifying exception for other formats with just the status' do
      formats = [:xsl, :php, :doc, :pdf, :csv, :xml]

      OpenStax::RescueFrom::WrappedException::NON_NOTIFYING.each do |ex|
        get :bad_action, exception: ex, format: formats.sample

        expected_status = OpenStax::RescueFrom::WrappedException::STATUS_MAP[ex]

        expect(response.body).to be_blank
        expect(response).to have_http_status(expected_status),
          "expected #{expected_status}, got #{response.status} - for #{ex}"
      end
    end

    it 'uses 500 for unknown exceptions in the status map' do
      get :bad_action, exception: 'OAuth2::Error'
      expect(response).to have_http_status(500)
      expect(response).to render_template('errors/any')
    end

    it 'does not send emails for non-notifying exceptions' do
      ActionMailer::Base.deliveries.clear

      OpenStax::RescueFrom::WrappedException::NON_NOTIFYING.each do |ex|
        get :bad_action, exception: ex
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    it 'emails for other exceptions' do
      ActionMailer::Base.deliveries.clear
      get :bad_action, exception: 'ArgumentError'
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end
  end
end
