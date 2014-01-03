require "bundler/gem_tasks"
require 'rake/testtask'
require 'cucumber/rake/task'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

desc "Run all CI tests" 
task :test_ci do
  Rake::Task['test'].invoke 
  Rake::Task['features'].invoke
end

task :default => :test_ci
