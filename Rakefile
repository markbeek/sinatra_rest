require 'rake/testtask'

desc "start webserver and person service"
task :run do
	ruby "-I. bin/person_rest_service.rb"
end

desc "run all tests using rake test"
Rake::TestTask.new("test") do |t|
	t.pattern = "test/test*.rb"
	t.warning = true
end

task :default => [:run]