class SecurityTransgression < Exception
end

module Apipie
  class ParamMissing < Exception
  end
end

module OAuth2
  class Error < Exception
    def response
      Rack::Response.new
    end
  end
end
