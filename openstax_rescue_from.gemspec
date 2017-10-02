# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'openstax/rescue_from/version'

Gem::Specification.new do |spec|
  spec.name          = "openstax_rescue_from"
  spec.version       = OpenStax::RescueFrom::VERSION
  spec.authors       = ["JP Slavinsky", "Joe Sak"]
  spec.email         = ["jps@kindlinglabs.com", "joe@avant-gardelabs.com"]

  spec.summary       = %q{Common exception `rescue_from` handling for OpenStax sites.}
  spec.homepage      = "https://github.com/openstax/rescue_from"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.0'

  spec.add_dependency "rails", '>= 3.1', '< 6.0'
  spec.add_dependency "exception_notification", '>= 4.1', '< 5.0'

  spec.add_development_dependency "sqlite3", '~> 1.3.10'
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec-rails", '~> 3.3.3'
  spec.add_development_dependency "pry-nav", '~> 0.2.4'
  spec.add_development_dependency "pry-rails", '~> 0.3.4'
  spec.add_development_dependency "database_cleaner", '~> 1.5.0'
end
