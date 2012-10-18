module MxitApi
  class Config
    attr_accessor :mxit_app_name
    attr_accessor :mxit_api_client_id
    attr_accessor :mxit_api_client_secret

    def initialize
      @mxit_app_name = "your_app_name"
      @mxit_api_client_id = "your_client_id"
      @mxit_api_client_secret = "your_client_secret"
    end
  end
end