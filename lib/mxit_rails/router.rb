module MxitRails
  class Router
    def self.url route
      path = []
      root = Rails.application.config.mxit_root
      path << root unless root.blank?
      path << route.to_s
      path = '/' + path.join('/')
    end
  end
end
