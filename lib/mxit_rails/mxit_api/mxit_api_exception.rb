module MxitRails::MxitApi
  class Exception < Exception
    attr_reader :message
    def initialize(message)
      @message = message
    end
  end
end