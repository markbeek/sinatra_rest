#run locally:
#ruby -I. bin/person_rest_service.rb
#OR
#bundle exec ruby bin/person_rest_service.rb prod -p $PORT

#for testing, using a different db:
#ruby -I. bin/person_rest_service.rb TEST

require 'sinatra'
require 'json/pure'
require_relative '../lib/dao/person_dao'

#since rack/test runs this program without args,
#our default will be to use the test db;
#for production, we pass in a parameter informing us
#to us the production db
PRODUCTION_DB = 'person_db'
db_name = 'test'
if ARGV[0] && ARGV[0].match(/prod/)
	db_name = PRODUCTION_DB
end
puts "********db_name: #{db_name}*********"

con = Mongo::Connection.new
db = con[db_name]
persons = db['persons']
person_dao = PersonDao.new(persons)

#browser verification filter
before '/hello' do
	content_type :txt
end

before %r{/person} do
	content_type "application/json"	#both browsers treat this as a download, have to open in 
end

####################
###BROWSER VERIFICATION METHOD
####################
get '/hello' do
	"hello"
end

####################
###REST SERVICE
####################

#Create (request must include a JSON body),
#and we're expecting person_id, name, and age;
#the dao itself will manufacture the resource url
post '/person' do
	begin
		req_body = get_request_body(request)
		person_data = json_to_hash(req_body)
		filtered_person_data = produce_person_hash(person_data)
		person = person_dao.create(filtered_person_data)
		JSON.generate(person)
	rescue
		status 400 #bad request
	end
end
	
#Retrieve
get '/person/:person_id' do
	person = person_dao.retrieve(params[:person_id])
	if person
		JSON.generate(person)
	else
		status 404	#Not Found
	end
end

#Update (request must include a JSON body with name and age)
#technically, this could be a put
post '/person/:person_id' do
	begin
		req_body = get_request_body(request)
		partial_person_data = json_to_hash(req_body)
		filtered_person_data = produce_partial_person_hash(partial_person_data)
		person = person_dao.update(params[:person_id], filtered_person_data)
		JSON.generate(person)
	rescue
		status 400 #bad request
	end
end

#Delete
delete '/person/:person_id' do
	person_dao.delete(params[:person_id])
end

#list of persons
get '/persons' do
	JSON.generate(YamlDao.new(data_file).list)
end

########################
#helper methods
#basic idea is that each will raise an exception
#if anything goes wrong, making
#it easier for calling methods to negotiate
#different patterns of faulty data without
#deeply nested conditionals
########################

def get_request_body(request)
	req_body = request.body.read
	if req_body
		req_body
	else
		raise "no request body"
	end
end

#will parse arg to hash,
#throw error if it's not a json object
def json_to_hash(json_obj)
	JSON.parse(json_obj)
end

#for create:
#checks submitted hash and returns a valid person hash
#if all is well, otherwise throws an exception
def produce_person_hash(person_data)
	person_id = person_data['person_id']
	name = person_data['name']
	age = person_data['age']
	if (person_id && name && age)
		age = Integer(age) #will raise an error if age is not an integer
		{"person_id" => person_id, "name" => name, "age" => age}	
	else
		raise "did not have necessary person"
	end
end

#for update:
#checks submitted hash and returns a valid hash
#with name and age
#if all is well, otherwise throws an exception
def produce_partial_person_hash(person_data)
	name = person_data['name']
	age = person_data['age']
	if (name && age)
		age = Integer(age) #will raise an error if age is not an integer
		{"name" => name, "age" => age}	
	else
		raise "did not have necessary person data"
	end
end

puts "person service started"