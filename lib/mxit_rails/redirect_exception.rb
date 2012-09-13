module MxitRails
  class RedirectException < MxitRails::Exception
    attr_accessor :route
  end
end