#start mongo with
#

#from root directory, run with
#rake test
#OR
#ruby -I. test/test_mongo_dao.rb

require 'test/unit'
require 'mongo'
require_relative '../lib/dao/mongo_dao'

#setup test db
CON = Mongo::Connection.new
DB = CON['test']
PERSONS = DB['persons']

#known person
KNOWN_PERSON_ID = 'msinclair'
KNOWN_PERSON_NAME = 'Mandy Sinclair'
KNOWN_AGE = 27

class MongoDaoTest < Test::Unit::TestCase

	def setup
	end
	
	#clean collection
	def teardown
		PERSONS.remove({"person_id" => KNOWN_PERSON_ID})
	end


	def test_create_person
		@test_person_id = PERSONS.insert(
			{"person_id" => KNOWN_PERSON_ID, "person_name" => KNOWN_PERSON_NAME, "age" => KNOWN_AGE}
		)
		puts "reached here"
		#@yaml_dao.create(new_person_id,person_info)
		#person = @yaml_dao.retrieve(new_person_id)
		#assert_equal(new_person_name, person[:name])
		#assert_equal(new_person_age, person[:age])
	end



=begin
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
		result = @yaml_dao.delete(KNOWN_PERSON_ID)
		assert_equal 1, result
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

	#just testing the default entries in the yaml test file
	def test_list
		person_data_list = @yaml_dao.list
		assert_equal 3, person_data_list.length
		person_data_list.each do |hash|
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