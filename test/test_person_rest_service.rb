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
	
	def test_get_persontext
		get '/persontest'
		puts "test_get_persontext, last_response.body: #{last_response.body}"
		hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal 'Mary', hash['name']
	end
	
	def test_get_person
		get '/person/cabbot'
		puts "test_get_person, last_response.body: #{last_response.body}"
		person_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal "Cindy Abbot", person_hash['name']
		assert_equal 21, person_hash['age']
	end
	
	def test_post
		req = JSON.generate({"name" => "Priscilla Mayberry", "age" => 23})
		post '/person', req
		response_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal "/person/prisci", response_hash['url']
puts "response_hash['url']: #{response_hash['url']}"
=begin
		#just for kicks, user the url for a get
		get response_hash['url']
		person_hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal "Priscilla Mayberry", person_hash['name']
		assert_equal 23, person_hash['age']	
=end
		
	end

end