#run from root with
#ruby -I. bin/person_rest_client.rb
#(after starting person service)

#for heroku, run with:
#ruby -I. bin/person_rest_client.rb http://severe-sword-1427.herokuapp.com

#this client will exercise the rest_client API

#it expects 
#an instance of the rest service to be running at the given URL
#an accessible instance of MongoDb to be running

require 'rest_client'
require 'json/pure'

KNOWN_PERSON_ID = "jastner"

DEFAULT_HOST = "http://localhost:4567"
host = DEFAULT_HOST
if ARGV[0] && ARGV[0].match(/http/)
	host = ARGV[0]
end

puts

puts "host: #{host}"

puts

#sanity check of the non-rest request
response = RestClient.get(host + "/hello")
puts "/hello response code: #{response.code}"
puts "/hello response: #{response}"

puts

=begin
#####################################################################
response = RestClient.post(
	(host + "/person"),
	JSON.generate({"person_id" => KNOWN_PERSON_ID, "name" => "Jayla Jastner", "age" => 23}), 
	:content_type => 'application/json'
) 
puts "post create /person response code: #{response.code}"
puts "post create /person response: #{response.body}"
puts

response = RestClient.post(
	(host + "/person/#{KNOWN_PERSON_ID}"),
	JSON.generate({"name" => "Mrs. Jayla Maynard", "age" => 24}), 
	:content_type => 'application/json'
)
puts "post update /person response code: #{response.code}"
puts "post update /person response: #{response.body}"
puts
#####################################################################
=end

#create a person, retrieve her, update her, delete her

#CREATE
response = RestClient.post(
	(host + "/person"),
	JSON.generate({"person_id" => KNOWN_PERSON_ID, "name" => "Jayla Jastner", "age" => 23}), 
	:content_type => 'application/json'
) 
puts "post create /person response code: #{response.code}"
puts "post create /person response: #{response.body}"
puts

#RETRIEVE
response = RestClient.get(host + "/person/#{KNOWN_PERSON_ID}")
puts "get /person/#{KNOWN_PERSON_ID} response code: #{response.code}"
puts "get /person/#{KNOWN_PERSON_ID} response: #{response.body}"
#just for curiosity's sake:
#puts "get /person/#{KNOWN_PERSON_ID} headers:" 
#p response.headers
puts

#UPDATE
response = RestClient.post(
	(host + "/person/#{KNOWN_PERSON_ID}"),
	JSON.generate({"name" => "Mrs. Jayla Maynard", "age" => 24}), 
	:content_type => 'application/json'
)
puts "post update /person response code: #{response.code}"
puts "post update /person response: #{response.body}"
puts

#check to make sure resource has changed
puts "CHECKING OUR UPDATE"
response = RestClient.get(host + "/person/#{KNOWN_PERSON_ID}")
puts "get /person/#{KNOWN_PERSON_ID} response code: #{response.code}"
puts "get /person/#{KNOWN_PERSON_ID} response: #{response.body}"
puts

#DELETE
response = RestClient.delete(host + "/person/#{KNOWN_PERSON_ID}")
puts "delete /person/#{KNOWN_PERSON_ID} response code: #{response.code}"
puts

#ensure that resource has been deleted
#note, on 404 response not found, RestClient throws an exception,
#so need to handle that instead of the response
begin
	response = RestClient.get(host + "/person/#{KNOWN_PERSON_ID}")
	#puts "get /person/#{KNOWN_PERSON_ID} response code: #{response.code}"
rescue => e
	puts "delete non-existing /person/#{KNOWN_PERSON_ID}
	puts "#{e.message}"
end
puts

puts "client has completed work"
