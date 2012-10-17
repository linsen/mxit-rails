module MxitApi
  class Exception < Exception
    attr_reader :message
    def initialize(message)
      super(message)
      @message = message
    end
  end
end