#convenient file-based CRUD database,
#backend for rest data,
#no heed to efficiency,concurrency,etc
#reads from and writes to yaml file on each call

require 'yaml'

class YamlDao

	#data expected to be an array
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
		#synchronize with file
		File.open(@file,'w') do |f|
			YAML.dump(@data,f)
		end
	end
	
	def retrieve(person_id)
		@data[person_id]
	end

	def update(person_id,updated_person_info)
		@data[person_id] = updated_person_info
		#synchronize with file
		File.open(@file,'w') do |f|
			YAML.dump(@data,f)
		end		
	end

	def delete(person_id)
		@data.delete(person_id)
		#synchronize with file
		File.open(@file,'w') do |f|
			YAML.dump(@data,f)
		end
	end	
	
end