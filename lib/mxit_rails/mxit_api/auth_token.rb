module MxitRails::MxitApi
  class AuthToken
    attr_reader :access_token, :type, :expires_in, :refresh_token, :expires_at

    def initialize(token_response)
      @access_token = token_response['access_token']
      @type = token_response['type']
      @expires_in = token_response['expires_in']
      @refresh_token = token_response['refresh_token']
      @scope = token_response['scope'].split

      @expires_at = Time.now + expires_in.seconds
    end

    def scope
      @scope.join(' ')
    end

    def has_expired?
      # For extreme latency check within 3 seconds.
      @expires_at - Time.now <= 3.0
    end

    def has_scopes?(scopes)
      (scopes - @scope).empty?
    end
  end
end