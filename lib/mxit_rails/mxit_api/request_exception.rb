module MxitRails::MxitApi
  class RequestException < MxitRails::MxitApi::Exception
    attr_reader :code
    def initialize(message, code)
      super(message)
      @code = code
    end
  end
end