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
PERSONS.create_index("person_id", :unique => true)
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


=begin
	def test_index_info

		PERSONS.drop_indexes;
		puts "index information before adding index: #{PERSONS.index_information}"
		puts
		puts "explain before adding index: #{PERSONS.find({'person_id' => 'aaaa'}).explain}"
		puts
		
		PERSONS.create_index("person_id", :unique => true)
		
		puts "index information after adding index: #{PERSONS.index_information}"
		puts
		puts "explain after adding index: #{PERSONS.find({'person_id' => 'aaaa'}).explain}"
	end
=end
	
	def test_create
		person = PERSON_DAO.create(
			{"person_id" => "jjam", "name" => "Janna Jamme", "age" => 18}
		)
		assert_equal 2, PERSONS.count()
		assert_equal "jjam", person['person_id']
		assert_equal "/person/jjam", person['url']
		assert (person[:_id].is_a? BSON::ObjectId)
	end

	#assuming there's an index on person_id, we shouldn't be able
	#to create the same person twice:
	#correct, but the _id returned from these non-insertions is NOT
	#the same as the existing _id in the DB; the driver increments it
	#anyway, which could lead to serious problems with identifying a entity;
	#the db record doesn't change, but you're led to believe it has a new index
	def test_create_repeat
		person = PERSON_DAO.create(
			{"person_id" => "jjam", "name" => "Janna Jamme", "age" => 18}
		)
		PERSONS.find().each do |person|
			p person
		end
		puts
		puts
		
		assert_equal 2, PERSONS.count()
		assert_equal "jjam", person['person_id']
		assert_equal "/person/jjam", person['url']
		assert (person[:_id].is_a? BSON::ObjectId)
		id = person[:_id]
		person2 = PERSON_DAO.create(
			{"person_id" => "jjam", "name" => "Janna Jamme", "age" => 18}
		)
		p person2[:_id]
		assert_equal 2, PERSONS.count() #still 2
		assert (person2[:_id].is_a? BSON::ObjectId)
		id2 = person2[:_id]
		#assert_equal(id,id2)	#this is not true, they increment, even though
		#the record in the db remains the same!!!

		person3 = PERSON_DAO.create(
			{"person_id" => "jjam", "name" => "Janna Jamme", "age" => 18}
		)
		p person3[:_id]
		person4 = PERSON_DAO.create(
			{"person_id" => "jjam", "name" => "Janna Jamme", "age" => 18}
		)
		p person4[:_id]
		person5 = PERSON_DAO.create(
			{"person_id" => "jjam", "name" => "Janna Jamme", "age" => 18}
		)
		p person5[:_id]
		puts
		
		assert_equal 2, PERSONS.count() #still 2	

		#same as the first read
		PERSONS.find().each do |person|
			p person
		end
		puts
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
		#updated_person is the hash returned by the dao, so we'll check it first
		assert_equal(KNOWN_PERSON_ID, updated_person['person_id'])
		assert_equal("Mandy Married", updated_person['name'])
		assert_equal(28, updated_person['age'])
		assert_equal("/person/#{KNOWN_PERSON_ID}", updated_person['url'])
		assert (updated_person["_id"].is_a? BSON::ObjectId)
		#now let's check the document from the collection to make sure
		#our returned value corresponds to reality
		retrieved_person = PERSON_DAO.retrieve(KNOWN_PERSON_ID)
		assert_not_nil(retrieved_person)
		assert_equal(KNOWN_PERSON_ID, retrieved_person["person_id"])
		assert_equal("Mandy Married", retrieved_person["name"])
		assert_equal(28, retrieved_person["age"])
		assert (retrieved_person["_id"].is_a? BSON::ObjectId)

puts
puts "retrieved_person"
p retrieved_person
puts

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
	
	def test_list
		person_list = PERSON_DAO.list
		assert_equal 1, person_list.length
		#add a couple more
		PERSON_DAO.create(
			{"person_id" => "test1", "name" => "Test One", "age" => 1}
		)
		PERSON_DAO.create(
			{"person_id" => "test2", "name" => "Test Two", "age" => 2}
		)
		person_list = PERSON_DAO.list
		assert_equal 3, person_list.length
		person_list.each do |person|
			assert_not_nil(person["person_id"])
			assert_not_nil(person["name"])
			assert_not_nil(person["age"])
			if (person["person_id"] == KNOWN_PERSON_ID)
				assert_equal KNOWN_PERSON_NAME, person["name"]
				assert_equal KNOWN_AGE, person["age"]
			#these two should have URLs because they were inserted by the DAO
			elsif (person["person_id"] == 'test1')
				assert_equal "Test One", person["name"]
				assert_equal 1, person["age"]
				assert_equal "/person/test1", person["url"]				
			elsif (person["person_id"] == 'test2')
				assert_equal "Test Two", person["name"]
				assert_equal 2, person["age"]
				assert_equal "/person/test2", person["url"]
			end
		end
	end

end