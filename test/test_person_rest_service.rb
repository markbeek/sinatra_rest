#from root directory, run with
#rake test
#OR
#ruby -I. test/test_person_rest_service.rb

require_relative "../bin/person_rest_service.rb"
require 'test/unit'
require 'rack/test'
require 'json'

class PersonServiceTest < Test::Unit::TestCase

	include Rack::Test::Methods
	
	def app
		Sinatra::Application
	end
	
	def test_get
		get '/persontest'
		puts last_response.body
		hash = JSON.parse(last_response.body)
		assert_equal 200, last_response.status
		assert_equal 'Mary', hash['name']
	end

end