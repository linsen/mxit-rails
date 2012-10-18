require "mxit_api/client"
require "mxit_api/auth_token"
require "mxit_api/exception"
require "mxit_api/request_exception"
require "mxit_api/config"

module MxitApi
  extend self
  attr_accessor :config

  # Call this method to modify defaults in your initializers.
  #
  # @example
  #   MxitApi.configure do |config|
  #     config.mxit_app_name = 'mxitmoney'
  #   end
  def configure
    self.config ||= MxitApi::Config.new
    yield(config)
  end
end

MxitApi.configure {}
