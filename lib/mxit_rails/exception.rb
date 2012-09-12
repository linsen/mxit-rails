module MxitRails
  class Exception < Exception
    attr_reader :message
    attr_reader :code
    def initialize message, code
      @message = message
      @code = code
    end
  end
end