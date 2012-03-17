#from root directory, run with
#rake test
#OR
#ruby -I. test/test_person_rest_service.rb

require_relative "../bin/person_rest_service.rb"
require 'test/unit'
require 'rack/test'
require 'json'
require 'rest_client'

DATA_FILE = 'test/baseline_persons.yaml'
TEST_PERSON_NAME = "Priscilla Mayberry"
TEST_PERSON_AGE = 23
TEST_PERSON_URL = "/person/prisci"

class PersonServiceTest < Test::Unit::TestCase

	include Rack::Test::Methods
	
	#write a clean a file with known data before each test
	def setup
		puts "setting up baseline file"
		system("ruby -I. test/baseline_person_resource_generator.rb")
		puts "baseline file is set up"
		@yaml_dao = YamlDao.new(DATA_FILE)
	end
	
	#delete file
	def teardown
		@yaml_dao = nil
		num_files_deleted = File.delete(DATA_FILE)
		assert_equal(1,num_files_deleted)
	end
	
	def app
		Sinatra::Application
	end

	def test_generate_person_id_short_name
		person_name = 'Magg'	#shorter than 6
		person_id = generate_person_id person_name
		assert_equal person_name.downcase, person_id
	end

	def test_generate_person_id_six_letter_name
		person_name = 'Mi Sole'	#equals 6 after strip
		person_id = generate_person_id person_name
		assert_equal "misole", person_id
		person_name = ' Mi Sole '	#equals 6 after strip
		person_id = generate_person_id person_name
		assert_equal "misole", person_id
		person_name = 'MiSole'	#equals 6 after strip
		person_id = generate_person_id person_name
		assert_equal "misole", person_id		
	end

	def test_generate_person_id_long_name
		person_name = 'Mel D. Masterson'
		person_id = generate_person_id person_name
		assert_equal "meldma", person_id
		person_name = ' Mel D. Masterson '
		person_id = generate_person_id person_name
		assert_equal "meldma", person_id
		person_name = 'Mel D. Masterson'
		person_id = generate_person_id person_name
		assert_equal "meldma", person_id		
	end

	def test_generate_person_id_no_name
		person_name = nil
		person_id = generate_person_id person_name
		assert_nil person_id
		person_name = ''
		person_id = generate_person_id person_name
		assert_nil person_id
	end
	
	def test_get_existing
		get '/person/cabbot'
		puts "test_get_person, last_response.body: #{last_response.body}"
		person_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal "Cindy Abbot", person_hash['name']
		assert_equal 21, person_hash['age']
	end

	def test_get_not_found

	end
	
	def test_post
		req_body = JSON.generate({"name" => TEST_PERSON_NAME, "age" => TEST_PERSON_AGE})
		post '/person', req_body
		response_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal TEST_PERSON_URL, response_hash['url']
puts "response_hash['url']: #{response_hash['url']}"
		#just for kicks, use the url for a get
		get response_hash['url']
		person_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal TEST_PERSON_NAME, person_hash['name']
		assert_equal TEST_PERSON_AGE, person_hash['age']	
	end
	
	#add a person and test, then delete and test
	#should return 1 on successful delete
	def test_delete_existing
		req_body = JSON.generate({"name" => TEST_PERSON_NAME, "age" => TEST_PERSON_AGE})
		post '/person', req_body
		response_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal TEST_PERSON_URL, response_hash['url']
		delete response_hash['url'] #delete '/person/prisci'
		response_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal 1,response_hash["deleted"]
	end

	def test_delete_not_found
		delete '/person/ajbjrt'
		assert_equal 404, last_response.status
	end

	#add a person and test, then delete and test, then delete again
	#should return 1 on first, 404 on second
	def test_delete_repeated
		req_body = JSON.generate({"name" => TEST_PERSON_NAME, "age" => TEST_PERSON_AGE})
		post '/person', req_body
		response_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal TEST_PERSON_URL, response_hash['url']
		url = response_hash['url']
		delete url #delete '/person/prisci'
		response_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status		
		assert_equal 1,response_hash["deleted"]
		delete url #delete '/person/prisci'
		assert_equal 404, last_response.status
	end
	
	#add a user, test, update the user, test, get the user, test
	def test_update_existing
		req_body = JSON.generate({"name" => TEST_PERSON_NAME, "age" => TEST_PERSON_AGE})
		post '/person', req_body
		response_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal TEST_PERSON_URL, response_hash['url']
		update_req_body = JSON.generate({"name" => TEST_PERSON_NAME, "age" => 24})
		url = response_hash['url']
		puts "MAB test_update_existing url: #{url}"
		post url, update_req_body #post '/person/prisci'	with JSON body
		response_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal 1, response_hash['updated']
		#now get the updated user and make sure the update has taken hold
		get url	#get 'person/prisci'
		response_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal TEST_PERSON_NAME, response_hash['name']
		assert_equal 24, response_hash['age']
	end

	def test_update_not_found
		post '/person/ajbjrt', JSON.generate({"name" => "whatever", "age" => 77})
		assert_equal 404, last_response.status
	end
	
end