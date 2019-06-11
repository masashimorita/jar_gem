require "bundler/gem_tasks"
require "rspec/core/rake_task"

task :precompile do
  require 'jbundler'
  config = JBundler::Config.new
  JBundler::LockDown.new( config ).lock_down
  JBundler::LockDown.new( config ).lock_down("--vendor")
end

RSpec::Core::RakeTask.new(:spec)

task :default => [:spec, :precompile]
