# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'openstax/rescue_from/version'

Gem::Specification.new do |spec|
  spec.name          = "openstax_rescue_from"
  spec.version       = OpenStax::RescueFrom::VERSION
  spec.authors       = ["JP Slavinsky", "Joe Sak"]
  spec.email         = ["jps@kindlinglabs.com", "joe@avant-gardelabs.com"]

  spec.summary       = "Common exception `rescue_from` handling for OpenStax sites."
  spec.homepage      = "https://github.com/openstax/rescue_from"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(/spec\//) }
  spec.bindir        = "bin"
  spec.executables   = ["console", "setup"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'

  spec.add_dependency "rails", '>= 3.1', '< 6.0'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rails-controller-testing"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "exception_notification"
end
