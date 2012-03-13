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

	def update(person_id,updated_person_info)
		@data[person_id] = updated_person_info
		sync	
	end

	def delete(person_id)
		@data.delete(person_id)
		sync
	end	
	
	private
	
	#synchronize with file
	def sync
		File.open(@file,'w') do |f|
			YAML.dump(@data,f)
		end	
	end
	
end