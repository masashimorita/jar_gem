require 'bundler'
require "rspec/core/rake_task"

task :precompile do
  require 'jbundler'
  config = JBundler::Config.new
  JBundler::LockDown.new( config ).lock_down
  JBundler::LockDown.new( config ).lock_down("--vendor")
end

RSpec::Core::RakeTask.new(:spec)

Bundler::GemHelper.install_tasks
task :default => [:spec, :precompile]
