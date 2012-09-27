$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mxit_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mxit-rails"
  s.version     = MxitRails::VERSION
  s.authors     = ["Linsen Loots"]
  s.email       = ["linsen.loots@gmail.com"]
  s.homepage    = "https://github.com/linsen/mxit-rails"
  s.summary     = "Templating and libraries for making Mxit apps in Rails"
  s.description = <<-EOF
    A gem that includes a simple and opinionated templating framework for Rails-based Mxit apps.
    This includes a rough layout, support for styles similar to CSS classes, wrapped inputs, and
    an elegant way to support Mxit's conversation-based interface.

    Later versions will also include wrappers for important Mxit APIs.
  EOF

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.3"
  s.add_dependency "sass-rails", "~> 3.2.1"
  
  s.add_development_dependency "sqlite3"
end
