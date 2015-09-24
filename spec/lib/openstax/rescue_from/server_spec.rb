require 'rails_helper'
require 'openstax/rescue_from/server'

RSpec.describe OpenStax::RescueFrom::Server do
  describe '.nickname' do
    it 'bases the nickname from url cname parts after tutor-' do
      Rails.application.secrets.mail_site_url = 'tutor-test.openstax.org'
      expect(described_class.nickname).to eq('test')

      Rails.application.secrets.mail_site_url = 'tutor-multi-word-cname.openstax.org'
      expect(described_class.nickname).to eq('multi-word-cname')
    end

    it 'recognizes production' do
      Rails.application.secrets.mail_site_url = 'tutor.openstax.org'
      expect(described_class.nickname).to eq('production')
    end

    it 'fallsback to non-conventional urls' do
      Rails.application.secrets.mail_site_url = 'something-wild.com'
      expect(described_class.nickname).to eq('something-wild.com')
    end

    it 'copes when mail_site_url nil' do
      Rails.application.secrets.mail_site_url = nil
      expect(described_class.nickname).to eq('unknown deploy')
    end
  end
end
