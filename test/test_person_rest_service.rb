#from root directory, run with
#rake test
#OR
#ruby -I. test/test_person_rest_service.rb

#NOTE: rack/test starts its own instance of the sinatra service; don't need to run it separately

require_relative "../bin/person_rest_service.rb"
require 'test/unit'
require 'rack/test'
require 'json/pure'
require 'rest_client'

#same db that will be used by rest_service in test mode
CON = Mongo::Connection.new
DB = CON['test']
PERSONS = DB['persons']

#known person
KNOWN_PERSON_ID = 'msinclair'
KNOWN_NAME = 'Mandy Sinclair'
KNOWN_AGE = 27
KNOWN_URL = "/person/msinclair"

#test person
TEST_PERSON_ID = 'test1'
TEST_NAME = 'Test One'
TEST_AGE = 1
TEST_URL = "/person/test1"

class PersonServiceTest < Test::Unit::TestCase

	include Rack::Test::Methods
	
	#write a clean a file with known data before each test
	def setup
		PERSONS.insert({
			"person_id" => KNOWN_PERSON_ID, 
			"name" => KNOWN_NAME, 
			"age" => KNOWN_AGE,
			"url" => KNOWN_URL
		})
		assert_equal 1, PERSONS.count()
	end
	
	#delete file
	def teardown
		PERSONS.remove()
		assert_equal 0, PERSONS.count()
	end
	
	def app
		Sinatra::Application
	end

	def test_get_existing
		get "/person/#{KNOWN_PERSON_ID}"
		person_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal KNOWN_PERSON_ID, person_hash['person_id']
		assert_equal KNOWN_NAME, person_hash['name']
		assert_equal KNOWN_AGE, person_hash['age']
		assert_equal KNOWN_URL, person_hash['url']
	end

	def test_get_not_found
		get 'person/obo'
		assert_equal 404, last_response.status
	end

	def test_post_create
		req_body = JSON.generate({"person_id" => TEST_PERSON_ID, "name" => TEST_NAME, "age" => TEST_AGE})
		post '/person', req_body
		response_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal TEST_PERSON_ID, response_hash['person_id']
		assert_equal TEST_NAME, response_hash['name']
		assert_equal TEST_AGE, response_hash['age']
		assert_equal TEST_URL, response_hash['url']
		#just for kicks, test the url for a get
		get response_hash['url']
		assert_equal TEST_PERSON_ID, response_hash['person_id']
		assert_equal TEST_NAME, response_hash['name']
		assert_equal TEST_AGE, response_hash['age']
		assert_equal TEST_URL, response_hash['url']	
	end	

	def test_post_create_no_request_body
		post '/person'
		assert_equal 400, last_response.status
	end

	def test_post_create_malformed_request_body
		post '/person', "regular string"
		assert_equal 400, last_response.status
	end

	def test_post_create_incomplete_person
		incomplete_req_body = JSON.generate({"person_id" => TEST_PERSON_ID, "age" => TEST_AGE})
		post '/person', incomplete_req_body
		assert_equal 400, last_response.status		
	end	
	
	def test_post_create_invalid_age
		invalid_req_body = JSON.generate({"person_id" => TEST_PERSON_ID, "name" => TEST_NAME, "age" => "a"})
		post '/person', invalid_req_body
		assert_equal 400, last_response.status		
	end	
	
	def test_post_update_existing
		update_req_body = JSON.generate({"name" => TEST_NAME, "age" => TEST_AGE})
		post "/person/#{KNOWN_PERSON_ID}", update_req_body
		response_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal KNOWN_PERSON_ID, response_hash['person_id']
		assert_equal TEST_NAME, response_hash['name']
		assert_equal TEST_AGE, response_hash['age']
		assert_equal KNOWN_URL, response_hash['url']
		#test the url for a get
		get response_hash['url']
		assert_equal KNOWN_PERSON_ID, response_hash['person_id']
		assert_equal TEST_NAME, response_hash['name']
		assert_equal TEST_AGE, response_hash['age']
		assert_equal KNOWN_URL, response_hash['url']
	end

	def test_post_update_no_request_body
		post "/person/#{KNOWN_PERSON_ID}"
		assert_equal 400, last_response.status
	end

	def test_post_update_malformed_request_body
		post "/person/#{KNOWN_PERSON_ID}", "regular string"
		assert_equal 400, last_response.status
	end

	def test_post_update_incomplete_person
		incomplete_req_body = JSON.generate({"person_id" => TEST_PERSON_ID})
		post "/person/#{KNOWN_PERSON_ID}", incomplete_req_body
		assert_equal 400, last_response.status		
	end	
	
	def test_delete
		assert_equal 1, PERSONS.count()
		delete "/person/#{KNOWN_PERSON_ID}"
		assert_equal 200, last_response.status
		puts "COUNT: #{PERSONS.count()}"
		assert_equal 0, PERSONS.count()
	end

	
	def test_delete_repeat
		assert_equal 1, PERSONS.count()
		delete "/person/#{KNOWN_PERSON_ID}"
		assert_equal 200, last_response.status
		assert_equal 0, PERSONS.count()
		delete "/person/#{KNOWN_PERSON_ID}"
		assert_equal 200, last_response.status
		assert_equal 0, PERSONS.count()
	end	
	
=begin

	def test_update_not_found
		post '/person/ajbjrt', JSON.generate({"name" => "whatever", "age" => 77})
		assert_equal 404, last_response.status
	end
	
	def test_update_no_request_body
		#first add a user using create post (no id)
		req_body = JSON.generate({"name" => TEST_PERSON_NAME, "age" => TEST_PERSON_AGE})
		post '/person', req_body
		response_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal TEST_PERSON_URL, response_hash['url']
		#now attempt to update the user but with no request body
		url = response_hash['url']
		post url
		assert_equal 400, last_response.status
	end

	def test_update_malformed_request_body
		#first add a user using create post (no id)
		req_body = JSON.generate({"name" => TEST_PERSON_NAME, "age" => TEST_PERSON_AGE})
		post '/person', req_body
		response_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal TEST_PERSON_URL, response_hash['url']
		#now attempt to update the user but with no request body
		url = response_hash['url']
		post url, "non-json string"
		assert_equal 400, last_response.status
	end

	#use the known list (note this is a list of hashes
	def test_persons_list
		get '/persons'
		response_list = JSON.parse(last_response.body)
		assert_equal 3, response_list.length
		response_list.each do |hash|
			assert_not_nil(hash["id"])
			assert_not_nil(hash["name"])
			assert_not_nil(hash["age"])
			if (hash["id"] == 'cabbot')
				assert_equal "Cindy Abbot", hash["name"]
				assert_equal 21, hash["age"]
			elsif (hash["id"] == 'msinclair')
				assert_equal "Mandy Sinclair", hash["name"]
				assert_equal 27, hash["age"]			
			elsif (hash["id"] == 'gzarkon')
				assert_equal "George Zarkon", hash["name"]
				assert_equal 22, hash["age"]			
			end
		end
	end
	
=end
	
end