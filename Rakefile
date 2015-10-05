#!/usr/bin/env rake

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

APP_RAKEFILE = File.expand_path('../spec/dummy/Rakefile', __FILE__)
load 'rails/tasks/engine.rake'

Bundler::GemHelper.install_tasks

require 'rspec/core'
require 'rspec/core/rake_task'

desc "Run all specs in spec directory (excluding plugin specs)"
RSpec::Core::RakeTask.new(:spec)

task :default => :spec







# require 'rake/testtask'

# Rake::TestTask.new(:spec => 'app:db:test:prepare') do |t|
#   t.libs << 'spec'
#   t.pattern = 'spec/**/*_spec.rb'
#   t.verbose = false
# end

# task :default => :spec













# require "bundler/gem_tasks"
# require "rspec/core/rake_task"

# RSpec::Core::RakeTask.new(:spec)

# task :default => :spec

# Bundler::GemHelper.install_tasks
# APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
# load 'rails/tasks/engine.rake'
