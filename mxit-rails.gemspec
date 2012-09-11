$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mxit-rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mxit-rails"
  s.version     = MxitRails::VERSION
  s.authors     = ["Linsen Loots"]
  s.email       = ["linsen.loots@gmail.com"]
  s.homepage    = "https://github.com/linsen/mxit-rails"
  s.summary     = "A gem to make creating mxit apps in Rails fast and pleasant."
  s.description = "A gem to make creating mxit apps in Rails fast and pleasant."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.3"

  s.add_development_dependency "sqlite3"
end
