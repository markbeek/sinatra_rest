require 'sinatra'
require 'json'
require 'yaml'
require_relative '../lib/dao/yaml_dao'

puts "starting person service"

#"production" data file
DEFAULT_DATA_FILE = 'data/persons.yaml'

#we may pass in a test data file,
#which we will use,
#or rake may pass in a file as part of its file list,
#which we want to ignore
data_file = DEFAULT_DATA_FILE
if ARGV[0] && ARGV[0].match(/yaml$/)
	data_file = ARGV[0]
end

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

	puts "MAB person_rest_service, entering create with id: #{params[:id]}"

	person_data = JSON.parse(request.body.read)
	person_dao = YamlDao.new(data_file)
	person_id = generate_person_id(person_data['name'])
	#puts "generate_user_id params[:name]: #{generate_user_id(params[:name])}"
	person_dao.create(person_id, {:name => person_data["name"], :age => person_data['age']})
	JSON.generate({"url" => "/person/#{person_id}"})
end

#Retrieve
get '/person/:id' do
	person_dao = YamlDao.new(data_file)
	person_data = person_dao.retrieve(params[:id])
	person_json = JSON.generate(person_data) 
end

#Update (request must include a JSON response body)
post '/person/:id' do
	
	puts "MAB person_rest_service, entering update with id: #{params[:id]}"

	person_data = JSON.parse(request.body.read)
	person_dao = YamlDao.new(data_file)
	result = person_dao.update(params[:id], person_data)
	if result == 1
		JSON.generate({"updated" => result})
	else
		status 404
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