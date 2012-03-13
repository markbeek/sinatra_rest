#from root directory, run with
#rake test
#OR
#ruby -I. test/test_yaml_dao.rb

require 'test/unit'
require 'yaml'
require_relative '../lib/dao/yaml_dao'

DATA_FILE = 'test/baseline_persons.yaml'
KNOWN_PERSON_ID = 'msinclair'
KNOWN_PERSON_NAME = 'Mandy Sinclair'
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
		num_files_deleted = File.delete(DATA_FILE)
		assert_equal(1,num_files_deleted)
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

	def test_create_person_sync_with_file
		new_person_id = 'ndancin'
		new_person_name = "Nora Dancin"
		new_person_age = 33
		person_info = {
			name: new_person_name,
			age: new_person_age
		}
		@yaml_dao.create(new_person_id,person_info)
		#check via file
		data = {}
		File.open(DATA_FILE) do |f|
			data = YAML.load(f)
		end
		person = data[new_person_id]
		assert_equal(new_person_name, person[:name])
		assert_equal(new_person_age, person[:age])
		#check via new dao
		yaml_dao2 = YamlDao.new(DATA_FILE)
		person = yaml_dao2.retrieve(new_person_id)
		assert_equal(new_person_name, person[:name])
		assert_equal(new_person_age, person[:age])
	end
	
	def test_retrieve_person
		person = @yaml_dao.retrieve(KNOWN_PERSON_ID)
		assert_not_nil(person)
		assert_equal(KNOWN_PERSON_NAME, person[:name])
		assert_equal(KNOWN_AGE, person[:age])
	end
	
	def test_update_person
		known_person_name = "Mandy Sinclair-Carter"
		known_person_age = 27
		updated_person_info = {
			name: known_person_name,
			age: known_person_age
		}
		@yaml_dao.update(KNOWN_PERSON_ID,updated_person_info)
		person = @yaml_dao.retrieve(KNOWN_PERSON_ID)
		assert_equal(known_person_name, person[:name])
		assert_equal(known_person_age, person[:age])
	end

	def test_update_person_sync_with_file
		known_person_name = "Mandy Sinclair-Carter"
		known_person_age = 27
		updated_person_info = {
			name: known_person_name,
			age: known_person_age
		}
		@yaml_dao.update(KNOWN_PERSON_ID,updated_person_info)
		#check via file
		data = {}
		File.open(DATA_FILE) do |f|
			data = YAML.load(f)
		end
		person = data[KNOWN_PERSON_ID]
		assert_equal(known_person_name, person[:name])
		assert_equal(known_person_age, person[:age])
		#check via new dao
		yaml_dao2 = YamlDao.new(DATA_FILE)
		person = yaml_dao2.retrieve(KNOWN_PERSON_ID)
		assert_equal(known_person_name, person[:name])
		assert_equal(known_person_age, person[:age])
	end
	
	def test_delete_person
		#sanity check, make sure person is there first
		person = @yaml_dao.retrieve(KNOWN_PERSON_ID)
		assert_not_nil(person)
		assert_equal(KNOWN_PERSON_NAME, person[:name])
		assert_equal(KNOWN_AGE, person[:age])
		#now test delete
		@yaml_dao.delete(KNOWN_PERSON_ID)
		assert_nil(@yaml_dao.retrieve(KNOWN_PERSON_ID))
	end

	def test_delete_person_sync_with_file
		#sanity check, make sure person is there first
		person = @yaml_dao.retrieve(KNOWN_PERSON_ID)
		assert_not_nil(person)
		assert_equal(KNOWN_PERSON_NAME, person[:name])
		assert_equal(KNOWN_AGE, person[:age])
	@yaml_dao.delete(KNOWN_PERSON_ID)
		#check via file
		data = {}
		File.open(DATA_FILE) do |f|
			data = YAML.load(f)
		end
		assert_nil(data[KNOWN_PERSON_ID])
		#check via new dao
		yaml_dao2 = YamlDao.new(DATA_FILE)
		assert_nil(yaml_dao2.retrieve(KNOWN_PERSON_ID))
	end
	
end