require 'yaml'

#user_id => info
persons = {
	"cabbot" => {
		name: "Cindy Abbot",
		age: 21
	},
	"msinclair" => {
		name: "Mandy Sinclair",
		age: 27
	},
	"gzarkon" => {
		name: "George Zarkon",
		age: 22
	}
}

File.open('test/baseline_persons.yaml','w') do |f|
	YAML.dump(persons,f)
end