module MxitApi
  class RequestException < MxitApi::Exception
    attr_reader :code
    def initialize(message, code)
      super(message)
      @code = code
    end
  end
end