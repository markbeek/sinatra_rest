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

before do
	content_type "application/json"	#both browsers treat this as a download, have to open in separate application 
	#content_type :txt	#this is rendered directly in the browser
end

get '/persontest' do
	JSON.generate({"name" => "Mary"})
end

get '/person/:id' do
	person_dao = YamlDao.new(data_file)
	person_data = person_dao.retrieve(params[:id])
	person_json = JSON.generate(person_data) 
end

post '/person' do
	puts "post params object"
	p params
	puts "request body: #{request.body.read}"
	puts
	#person_dao = YamlDao.new(data_file)
	#person_dao.create(params[:id],{:name => params[:name], :age => params[:age]})
	JSON.generate({"url" => "/person/pmayber"})
end

puts "person service started"