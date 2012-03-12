class YamlDao

	#data expected to be an array
	def initialize(file)
		@file = file
		@data = nil
		File.open(@file) do |f|
			@data = YAML.load(f)
		end
		@data ||= []
	end

	def create(obj)
		@data << obj
		File.open(@file,'w') do |f|
			YAML.dump(@data,f)
		end
	end
	
	def retrieve
		File.open(@file) do |f|
			@data= YAML.load(f)
		end
		@data ||= []
	end
	
end