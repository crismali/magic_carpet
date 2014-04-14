$:.push File.expand_path("../lib", __FILE__)

require "magic_carpet/version"

Gem::Specification.new do |s|
  s.name        = "magic_carpet"
  s.version     = MagicCarpet::VERSION
  s.authors     = ["Michael Crismali", "Dayton Nolan"]
  s.email       = ["michael.crismali@gmail.com", "daytonn@gmail.com"]
  s.homepage    = "https://github.com/daytonn/magic_carpet"
  s.summary     = "A whole new world of rails javascript testing"
  s.description = "MagicCarpet renders any view with stub data from your front-end test suite (ie. jasmine) so you can test your js against the real world."
  s.license     = "Apache"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 3.2"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "jasmine-rails"
  s.add_development_dependency "fuubar"
  s.add_development_dependency "unicorn-formatter"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "pry-nav"
end
