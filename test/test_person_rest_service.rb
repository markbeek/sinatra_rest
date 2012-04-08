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
		assert_nil person_hash['_id']
	end

	def test_get_not_found
		get 'person/obo'
		assert_equal 404, last_response.status
	end

	def test_post_create
		req_body = JSON.generate({"person_id" => TEST_PERSON_ID, "name" => TEST_NAME, "age" => TEST_AGE})
		post '/person', req_body
		response_hash = JSON.parse(last_response.body)
		
		puts
		puts "in test, hash from create:"
		p response_hash
		puts
		
		assert_equal 200, last_response.status
		assert_equal TEST_PERSON_ID, response_hash['person_id']
		assert_equal TEST_NAME, response_hash['name']
		assert_equal TEST_AGE, response_hash['age']
		assert_equal TEST_URL, response_hash['url']
		assert_nil response_hash['_id']
		#just for kicks, test the url for a get
		get response_hash['url']
		assert_equal TEST_PERSON_ID, response_hash['person_id']
		assert_equal TEST_NAME, response_hash['name']
		assert_equal TEST_AGE, response_hash['age']
		assert_equal TEST_URL, response_hash['url']	
		assert_nil response_hash['_id']
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
		assert_nil response_hash['_id']
		#test the url for a get
		get response_hash['url']
		response_hash = JSON.parse(last_response.body)
		assert_equal KNOWN_PERSON_ID, response_hash['person_id']
		assert_equal TEST_NAME, response_hash['name']
		assert_equal TEST_AGE, response_hash['age']
		assert_equal KNOWN_URL, response_hash['url']
		assert_nil response_hash['_id']
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
		puts "COUNT  again: #{PERSONS.count()}"
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
	
	def test_persons_list
		get '/persons'
		persons = JSON.parse(last_response.body)
		assert_equal 1, persons.length
		#add a couple more and test
		req_body = JSON.generate({"person_id" => TEST_PERSON_ID, "name" => TEST_NAME, "age" => TEST_AGE})
		post '/person', req_body
		req_body = JSON.generate({"person_id" => "test2", "name" => "Test Two", "age" => 2})
		post '/person', req_body
		get '/persons'
		persons = JSON.parse(last_response.body)
		assert_equal 3, persons.length
		puts "LIST COUNT: #{PERSONS.count()}"
		persons.each do |person|
			assert_not_nil(person["person_id"])
			assert_not_nil(person["name"])
			assert_not_nil(person["age"])
			assert_not_nil(person["url"])
			if (person["person_id"] == KNOWN_PERSON_ID)
				assert_equal KNOWN_NAME, person["name"]
				assert_equal KNOWN_AGE, person["age"]
				assert_equal KNOWN_URL, person["url"]
				assert_nil person['_id']
			#these two should have URLs because they were inserted by the DAO
			elsif (person["person_id"] == TEST_PERSON_ID)
				assert_equal TEST_NAME, person["name"]
				assert_equal TEST_AGE, person["age"]
				assert_equal TEST_URL, person["url"]
				assert_nil person['_id']
			elsif (person['person_id'] == 'test2')
				assert_equal "Test Two", person["name"]
				assert_equal 2, person["age"]
				assert_equal "/person/test2", person["url"]
				assert_nil person['_id']
			end
		end
	end
	
end