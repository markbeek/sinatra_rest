#convenient file-based CRUD database,
#backend for rest data,
#no heed to efficiency,concurrency,etc
#reads from and writes to yaml file on each call

require 'mongo'

PATH = "/person/"

class PersonDao

	def initialize(persons) #collection
		@persons = persons
	end

	#input: hash of person information, representing mongo JSON object
	#return: hash of object, including mongo-generated _id and URL
	def create(person_info)
		person_info["url"] = PATH + person_info["person_id"]
		@persons.insert(person_info)
		person_info
	end
	
	#person_id is the business key of the collection;
	#returns a person hash, or nil if no person is found
	def retrieve(person_id)
		@persons.find_one({"person_id" => person_id})
	end
	
	#here we are updating by replacement,
	#ensuring that we have a url if the doc doesn't provide one;
	#if there is no such person to update, we raise an exception
	def update(person_id, updated_person_info)
		person = @persons.find_one({"person_id" => person_id})
		raise ("no such person: #{person_id}") if person.nil?
		person['name'] = updated_person_info['name']
		person['age'] = updated_person_info['age']
		person['url'] = PATH + person_id
		@persons.update({"person_id" => person_id}, person, :safe => true)
		person
	end

	#ruby mongo driver remove method apparently always returns true,
	#so we can get no additional information from the return value
	def delete(person_id)
		@persons.remove({"person_id" => person_id})
	end

	#return list all persons
	def list
		persons = []
		@persons.find().each do |person|
			persons << person
		end
		persons
	end

end