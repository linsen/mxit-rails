module MxitRails
  class Engine < ::Rails::Engine
    initializer "precompile", :group => :all do |app|
      app.config.assets.precompile += %w( mxit_rails/emulator.js mxit_rails/emulator.css mxit_rails/included.css )
    end
  end
end
