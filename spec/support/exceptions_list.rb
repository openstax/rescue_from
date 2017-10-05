class SecurityTransgression < StandardError
end

module Apipie
  class ParamMissing < StandardError
  end
end

module OAuth2
  class Error < StandardError
    def response
      Rack::Response.new
    end
  end
end
