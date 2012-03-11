require 'rake/testtask'

desc "run the people generator to start with up-to-date list of people"
task :generate_persons do
	ruby "-I. data/person_resource_generator.rb"
end

desc "start webserver and people service"
task :run_service do
	ruby "-I. person_rest_service.rb"
end

desc "run all tests using rake test"
Rake::TestTask.new("test" => [:generate_persons]) do |t|
	t.pattern = "test/test*.rb"
	t.warning = true
end

task :default => [:run_service]