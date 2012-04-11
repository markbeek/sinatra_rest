#run locally:

#start mongo

#ruby -I. bin/person_rest_service.rb dev
#(prod indicates that we are using production rather than test db)
#OR
#bundle exec ruby bin/person_rest_service.rb dev
#(dev indicates we are running locally using local db)

#remote (in Procfile)
#bundle exec -I. ruby bin/person_rest_service.rb prod -p $PORT



require 'sinatra'
require 'json/pure'
require 'uri'
require_relative '../lib/dao/person_dao'

#since rack/test runs this program without args,
#our default will be to use the test db;
#for production, we pass in a parameter informing us
#to us the production db
DEV_DB = 'person_db'
db_name = 'test'
env = 'nonprod'
if ARGV[0]
	if ARGV[0].match(/dev/)
		db_name = DEV_DB
	elsif ARGV[0].match(/prod/)
		env = 'prod'
	end
end
puts "********db_name: #{db_name}*********"

#production-specific info
#puts "MONGOHQ_URL: #{ENV['MONGOHQ_URL']}"
#uri = URI.parse(ENV['MONGOHQ_URL'])
#puts "uri.host: #{uri.host}"
#puts "uri.port: #{uri.port}"
#puts "uri.path(this is db name): #{uri.path}"
#puts "uri.user: #{uri.user}"
#puts "uri.password: #{uri.password}"

#PRODUCTION
#for now, I must manually authenticate
if env == 'prod'
	uri = URI.parse(ENV['MONGOHQ_URL'])
	con = Mongo::Connection.new(uri.host,uri.port)
	db_name = uri.path.gsub(/^\//,'')
	db = con[db_name]
	db.authenticate('heroku','password')
else #test or dev
	con = Mongo::Connection.new("localhost","27017")
	db = con[db_name]
end	
	
persons = db['persons']
person_dao = PersonDao.new(persons)

=begin
#alternate production approaches
#I changed the default password for my heroku user,
#but apparently the given url still has the original one
#so I can't use the automated version of authentication
#if I ever create another heroku account, I'll keep the default
con = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
db = con.db(uri.path.gsub(/^\//, ''))
persons = db['persons']
person_dao = PersonDao.new(persons)
=end

=begin
#using my user
con = Mongo::Connection.new(uri.host,uri.port)
db_name = uri.path.gsub(/^\//,'')
puts "dbname: #{db_name}"
db = con[db_name]
db.authenticate("mb...","standard")
persons = db['persons']
person_dao = PersonDao.new(persons)
=end

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
		person.delete(:_id) #service should not return technical keys, only business information
		JSON.generate(person)
	rescue
		status 400 #bad request
	end
end
	
#Retrieve
get '/person/:person_id' do
	person = person_dao.retrieve(params[:person_id])
	if person
		person.delete("_id") #service should not return technical keys, only business information
		JSON.generate(person)
	else
		status 404	#Not Found
	end
end

#Update (request must include a JSON body with name and age)
post '/person/:person_id' do
	begin
		req_body = get_request_body(request)
		partial_person_data = json_to_hash(req_body)
		filtered_person_data = produce_partial_person_hash(partial_person_data)
		person = person_dao.update(params[:person_id], filtered_person_data)
		person.delete("_id") #service should not return technical keys, only business information
		JSON.generate(person)
	rescue
		status 400 #bad request
	end
end

#Delete
delete '/person/:person_id' do
	person_dao.delete(params[:person_id])
end

#list of persons (each of which is a hash)
get '/persons' do
	persons = person_dao.list
	persons.each do |person|
		person.delete("_id") #service should not return technical keys, only business information
	end
	JSON.generate(persons)
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