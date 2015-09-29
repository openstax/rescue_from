require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

Bundler::GemHelper.install_tasks
APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'
