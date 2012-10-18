module MxitApi
  module ControllerExtensions
    def mxit_api
      @mxit_api ||= begin
        client = MxitApi::Client.new(MxitApi.config.mxit_app_name,
          MxitApi.config.mxit_api_client_id, MxitApi.config.mxit_api_client_secret)
      end
    end

    # type = :user | :app
    def load_mxit_auth_token type 
      auth_tokens = session[:mxit_auth_tokens]
      if auth_tokens
        auth_token = auth_tokens[type]
        if auth_token and not auth_token.has_expired?
          return auth_token
        end
      end

      nil
    end

    # type = :user | :app
    def save_mxit_auth_token type, auth_token
      auth_tokens = (session[:mxit_auth_tokens] ||= {})
      auth_tokens[type] = auth_token
    end
  end
end
