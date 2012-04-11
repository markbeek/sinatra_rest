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

#DEFAULT_HOST = "http://localhost:4567"
DEFAULT_HOST = "http://severe-sword-1427.herokuapp.com"
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
#############################
#TEST
#############################
response = nil
begin
	response = RestClient.get(host + "/person/#{KNOWN_PERSON_ID}")
	puts "get /person/#{KNOWN_PERSON_ID} response code: #{response.code}"
	puts "get /person/#{KNOWN_PERSON_ID} response: #{response.body}"
	puts
rescue => e
	puts ("e.message: #{e.message}")
	puts "e: #{e}"
	puts "response.body: #{response.body}" if response
end
=end


#create a person, retrieve her, update her, delete her

#we will always attempt to delete no matter what, so wrap rest in try/catch block

begin

rescue => e
		puts (e.message)
		p e
ensure
	#DELETE
	response = RestClient.delete(host + "/person/#{KNOWN_PERSON_ID}")
	puts "delete /person/#{KNOWN_PERSON_ID} response code: #{response.code}"
	puts
end


#check whether resource has been deleted
#note, on 404 response not found, RestClient throws an exception,
#so need to handle that instead of the response
begin
	response = RestClient.get(host + "/person/#{KNOWN_PERSON_ID}")
	#puts "get /person/#{KNOWN_PERSON_ID} response code: #{response.code}"
rescue => e
	puts "get non-existing /person/#{KNOWN_PERSON_ID}"
	puts "#{e.message}"
end
puts

puts "client has completed work"
