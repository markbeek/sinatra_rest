#convenient file-based CRUD database,
#backend for rest data,
#no heed to efficiency,concurrency,etc
#reads from and writes to yaml file on each call

require 'yaml'

class YamlDao

	#data expected to be a hash of hashes, person_id => {person_data}
	def initialize(file)
		@file = file
		@data = nil
		File.open(@file) do |f|
			@data = YAML.load(f)
		end
		@data ||= {}	
	end

	def create(person_id,person_info)	#string,hash
		@data[person_id] = person_info
		sync
	end
	
	def retrieve(person_id)
		@data[person_id]
	end

	#return 1 on successful update, else 0
	def update(person_id,updated_person_info)
		if @data[person_id]
			@data[person_id] = updated_person_info
			sync
			1
		else
			0
		end
	end

	#return 1 if a deletion actually occurred, 0 if nothing to delete
	def delete(person_id)
		if @data[person_id]
			@data.delete(person_id)
			sync
			1
		else
			0
		end
	end	
	
	private
	
	#synchronize with file
	def sync
		File.open(@file,'w') do |f|
			YAML.dump(@data,f)
		end	
	end
	
end