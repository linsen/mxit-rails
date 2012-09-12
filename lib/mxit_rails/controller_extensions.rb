module MxitRails
  module ControllerExtensions
    def mxit_style name, content
      MxitRails::Styles.add name, content
    end
  end
end
ActionController::Base.extend(MxitRails::ControllerExtensions)
