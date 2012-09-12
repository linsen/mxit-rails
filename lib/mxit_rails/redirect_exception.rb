module MxitRails
  class RedirectException < MxitRails::Exception
    attr_accessor :route
    attr_accessor :step
  end
end