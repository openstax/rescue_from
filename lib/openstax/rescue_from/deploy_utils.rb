module OpenStax
  module RescueFrom
    class DeployUtils
      def self.server_nickname
        url = Rails.application.secrets.mail_site_url || 'unknown deploy'
        match = url.match(/\Atutor-(.+)\.openstax/)

        if url == 'tutor.openstax.org'
          'production'
        elsif match && match[1]
          match[1]
        else
          url
        end
      end
    end
  end
end
