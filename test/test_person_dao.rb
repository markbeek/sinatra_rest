#start mongo with
#

#from root directory, run with
#rake test
#OR
#ruby -I. test/test_person_dao.rb

require 'test/unit'
require 'mongo'
require_relative '../lib/dao/person_dao'

#setup test db
CON = Mongo::Connection.new
DB = CON['test']
PERSONS = DB['persons']
PERSON_DAO = PersonDao.new(PERSONS)

#known person
KNOWN_PERSON_ID = 'msinclair'
KNOWN_PERSON_NAME = 'Mandy Sinclair'
KNOWN_AGE = 27

class MongoDaoTest < Test::Unit::TestCase

	#create a known person for testing retrieve, update, delete
	def setup
		@test_person_id = PERSONS.insert(
			{"person_id" => KNOWN_PERSON_ID, "name" => KNOWN_PERSON_NAME, "age" => KNOWN_AGE}
		)
		assert_equal 1, PERSONS.count()
	end
	
	#clean collection
	def teardown
		PERSONS.remove()
		assert_equal 0, PERSONS.count()
	end


	def test_create
		person = PERSON_DAO.create(
			{"person_id" => "jjam", "name" => "Janna Jamme", "age" => 18}
		)
		assert_equal 2, PERSONS.count()
		assert_equal "jjam", person['person_id']
		assert_equal "/person/jjam", person['url']
		assert (person[:_id].is_a? BSON::ObjectId)
	end
	
	def test_retrieve
		person = PERSON_DAO.retrieve(KNOWN_PERSON_ID)
		assert_not_nil(person)
		assert_equal(KNOWN_PERSON_ID, person["person_id"])
		assert_equal(KNOWN_PERSON_NAME, person["name"])
		assert_equal(KNOWN_AGE, person["age"])
		assert (person["_id"].is_a? BSON::ObjectId)
	end

	#asking for a person not in the collection
	def test_retrieve_nil
		person = PERSON_DAO.retrieve("non_existent_person")
		assert_nil(person)
	end
	
	def test_update_person
		updated_person_info = {
			"name" => "Mandy Married",
			"age" => 28
		}
		updated_person = PERSON_DAO.update(KNOWN_PERSON_ID,updated_person_info)
		assert_equal("Mandy Married", updated_person['name'])
		assert_equal(28, updated_person['age'])
		assert_equal("/person/#{KNOWN_PERSON_ID}", updated_person['url'])
		assert (updated_person["_id"].is_a? BSON::ObjectId)
	end

	def test_update_nonexistent_person
		updated_person_info = {
			"name" => "anything",
			"age" => 98
		}
		assert_raise (RuntimeError) {PERSON_DAO.update("nosuchperson",updated_person_info)}
	end
	
	def test_delete_person
		#sanity check, make sure person is there first
		person = PERSON_DAO.retrieve(KNOWN_PERSON_ID)
		assert_not_nil(person)
		assert_equal(KNOWN_PERSON_NAME, person['name'])
		assert_equal(KNOWN_AGE, person['age'])
		#now test delete
		PERSON_DAO.delete(KNOWN_PERSON_ID)
		assert_equal(0,PERSONS.count())
		assert_nil(PERSON_DAO.retrieve(KNOWN_PERSON_ID))
	end

	def test_delete_nonexistent_person
		PERSON_DAO.delete("nonperson")
		assert_equal(1,PERSONS.count())
	end
	
end