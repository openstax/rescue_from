module OpenStax
  module RescueFrom
    class Error
      def self.id
        "%06d#{SecureRandom.random_number(10**6)}"
      end
    end
  end
end
