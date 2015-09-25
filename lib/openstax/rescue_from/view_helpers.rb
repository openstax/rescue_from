module OpenStax
  module RescueFrom
    module ViewHelpers
      def openstax_rescue_from_contact_info
        info = OpenStax::RescueFrom.configuration.contact_name

        if info.match(/\S+@\S+\.\w{2,4}/)
          mail_to info
        elsif info.match(/\S+\.\w{2,4}\z/)
          info = info.match(/\Ahttps?:\/\//) ? info : "http://#{info}"
          link_to info, info
        else
          info
        end
      end
    end
  end
end
