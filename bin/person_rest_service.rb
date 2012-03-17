#to do:
#handle more error conditions: JSON object, but without name or age

require 'sinatra'
require 'json'
require 'yaml'
require_relative '../lib/dao/yaml_dao'

puts "starting person service"

#use test data file by default
DEFAULT_DATA_FILE = 'test/baseline_persons.yaml'

#we may pass in a test data file,
#which we will use,
#or rake may pass in a file as part of its file list,
#which we want to ignore
data_file = DEFAULT_DATA_FILE
if ARGV[0] && ARGV[0].match(/yaml$/)
	data_file = ARGV[0]
end
puts "********data_file: #{data_file}*********"

def generate_person_id(person_name)
	(person_name && !person_name.empty?) ? person_name.downcase.gsub(/\s/, '').gsub(/\./,'').slice(0..5) : nil
end

#either seems to test out
before do
	content_type "application/json"	#both browsers treat this as a download, have to open in separate application 
	#content_type :txt	#this is rendered directly in the browser
end

#Create (request must include a JSON response body)
post '/person' do
	req_body = request.body.read
	if req_body
		begin
			person_data = JSON.parse(req_body)
			person_dao = YamlDao.new(data_file)
			person_id = generate_person_id(person_data['name'])
			person_dao.create(person_id, {:name => person_data["name"], :age => person_data['age']})
			JSON.generate({"url" => "/person/#{person_id}"})
		rescue => e
			puts "MAB error message: #{e.message}"
			status 400	#Bad Request
		end
	else
		status 400 #Bad Request
	end
end

#Retrieve
get '/person/:id' do
	person_dao = YamlDao.new(data_file)
	person_data = person_dao.retrieve(params[:id])
	puts "MAB person_data: #{person_data}"
	if person_data
		person_json = JSON.generate(person_data)
	else
		status 404	#Not Found
	end
end

#Update (request must include a JSON response body)
post '/person/:id' do
	req_body = request.body.read
	if req_body
		begin
			person_data = JSON.parse(req_body)
			person_dao = YamlDao.new(data_file)
			result = person_dao.update(params[:id], person_data)
			if result == 1
				JSON.generate({"updated" => result})
			else
				status 404 #Not Found
			end
		rescue => e
			puts "error message: #{e.message}"
			status 400	#Bad Request
		end
	else
		status 400 #Bad Request
	end
end

#Delete
delete '/person/:id' do
	person_dao = YamlDao.new(data_file)
	result = person_dao.delete(params[:id])
	if result == 1
		JSON.generate("deleted" => result)
	else
		status 404
	end
end



puts "person service started"