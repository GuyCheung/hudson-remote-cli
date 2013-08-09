#!/usr/bin/env rake
require "bundler/gem_tasks"

task :default do
  Rake::Task['build'].execute
end

desc 'Run rspec examples'
task :rspec do
  sh 'rspec spec'
end
