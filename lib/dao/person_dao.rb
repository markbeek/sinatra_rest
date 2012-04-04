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
		person_info['url'] = PATH + person_info["person_id"]
		@persons.insert(person_info)
		person_info
	end
	
	#person_id is the business key of the collection
	def retrieve(person_id)
		@persons.find_one({"person_id" => person_id})
	end

=begin
	#return 1 on successful update, else 0
	def update(id,updated_person_info)
		if @data[person_id]
			@data[person_id] = updated_person_info
			sync
			1
		else
			0
		end
	end

	#return 1 if a deletion actually occurred, 0 if nothing to delete
	def delete(id)
		if @data[person_id]
			@data.delete(person_id)
			sync
			1
		else
			0
		end
	end

	#return list of maps with id absorbed into the map this time
	#{"id" => id, "name" => name, "age" => age}
	def list
		@data.keys.map do |key| 
			{"id" => key, "name" => @data[key][:name], "age" => @data[key][:age]}
		end
	end

=end	
	
end