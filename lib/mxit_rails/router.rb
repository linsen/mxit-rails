module MxitRails
  class Router
    def self.url route, step=nil
      path = []
      root = Rails.application.config.mxit_root
      path << root unless root.blank?
      path << route.to_s
      path << step.to_s unless step.nil?
      path = '/' + path.join('/')
    end
  end
end
