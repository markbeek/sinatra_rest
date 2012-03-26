#run from root with
#ruby -I. bin/person_rest_client.rb
#(after starting person service)

#this client will exercise the rest_client API, using

#it expects a real instance of the rest service to be running
#at the given URL, unlike the test classes, which use rack/test
#and start their own instance

require 'rest_client'
require 'json/pure'

DEFAULT_HOST = "http://localhost:9393"

host = DEFAULT_HOST
if ARGV[0] && ARGV[0].match(/http/)
	host = ARGV[0]
end

#sanity check of the non-rest request
response = RestClient.get(host + "/hello")
puts "/hello response code: #{response.code}"
puts "/hello response: #{response}"

puts

#test person retrieval
response = RestClient.get(host + "/person/cabbot")
puts "/person/cabbot response code: #{response.code}"
puts "/person/cabbot response: #{response}"

puts

#test person creation with post raw payload
response = RestClient.post(
	(host + "/person"),
	JSON.generate({"name" => "Miranda Havenstock", "age" => 38}), 
	:content_type => 'application/json'
) 
puts "/person response code: #{response.code}"
puts "/person response: #{response}"
