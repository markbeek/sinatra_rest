require 'sinatra'
require 'json'
require 'yaml'
require_relative '../lib/dao/yaml_dao'

puts "starting person service"

DATA_FILE = 'data/persons.yaml'

before do
	#content_type "application/json"	#both browsers treat this as a download, have to open in separate application 
	content_type :txt	#this is rendered directly in the browser
end

get '/person/:id' do
	person_dao = YamlDao.new(DATA_FILE)
	person_data = person_dao.retrieve(params[:id])
	person_json = JSON.generate(person_data) 
end

post '/person' do
	p params
	#person_dao = YamlDao.new(DATA_FILE)
	#person_dao.create(params[:id],{:name => params[:name], :age => params[:age]})
	"OK"
end

puts "person service started"