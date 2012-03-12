#run with
#rake test
#OR
#ruby -I. test/test_yaml_dao.rb

require 'test/unit'
require_relative '../lib/dao/yaml_dao.rb'

DATA_FILE = 'test_persons.yaml'

class YamlDaoTest < Test::Unit::TestCase

	#write a clean a file with known data before each test
	def setup
		system("ruby -I. data/test_person_resource_generator.rb")
		yaml_dao = YamlDao.new(DATA_FILE)
	end
	
	#delete file
	def teardown
		yaml_dao = nil
		#File.delete
	end

	def test_add_person
		assert(1==1)
	end

	def test_retrieve_person
		assert(1==1)
	end
	
end