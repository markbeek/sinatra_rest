desc "run the people generator to start with up-to-date list of people"
task :generate_people do
	ruby "-I. person_resource_generator.rb"
end

desc "start webserver and people service"
task :run_service do
	ruby "-I. people_rest_service.rb"
end

task :default => [:generate_people,:run_service]