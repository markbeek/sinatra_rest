#from root directory, run with
#rake test
#OR
#ruby -I. test/test_yaml_dao.rb

require 'test/unit'
require 'yaml'
require_relative '../lib/dao/yaml_dao.rb'

DATA_FILE = 'test/baseline_persons.yaml'
KNOWN_USER = 'msinclair'
KNOWN_USER_NAME = 'Mandy Sinclair'
KNOWN_AGE = 27

class YamlDaoTest < Test::Unit::TestCase

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
		#File.delete
	end

	def test_create_person
		new_person_id = 'bbastion'
		new_person_name = "Bette Bastion"
		new_person_age = 26
		person_info = {
			name: new_person_name,
			age: new_person_age
		}
		@yaml_dao.create(new_person_id,person_info)
		person = @yaml_dao.retrieve(new_person_id)
		assert_equal(new_person_name, person[:name])
		assert_equal(new_person_age, person[:age])
	end

	def test_create_person_synch_with_file
		new_person_id = 'ndancin'
		new_person_name = "Nora Dancin"
		new_person_age = 33
		person_info = {
			name: new_person_name,
			age: new_person_age
		}
		@yaml_dao.create(new_person_id,person_info)
		person = @yaml_dao.retrieve(new_person_id)
		assert_equal(new_person_name, person[:name])
		assert_equal(new_person_age, person[:age])
		data = {}
		#check via file
		File.open(DATA_FILE) do |f|
			data = YAML.load(f)
		end
		person = data[new_person_id]
		assert_equal(new_person_name, person[:name])
		assert_equal(new_person_age, person[:age])
		#check via new dao
		yaml_dao2 = YamlDao.new(DATA_FILE)
		person = yaml_dao2.retrieve(new_person_id)
		person = yaml_dao2.retrieve(new_person_id)
		assert_equal(new_person_name, person[:name])
		assert_equal(new_person_age, person[:age])
	end
	
	def test_retrieve_person
		person = @yaml_dao.retrieve(KNOWN_USER)
		assert_equal(KNOWN_USER_NAME, person[:name])
		assert_equal(KNOWN_AGE, person[:age])
	end
	
end