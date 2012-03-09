require 'yaml'

cindy = {
	name: "Cindy Shumaker",
	age: 21
}

mandy = {
	name: "Mandy Sinclair",
	age: 27
}

georgeanne = {
	name: "Georgeanne Senese",
	age: 22
}

people = {
	"cindy" => {
		name: "Cindy Shumaker",
		age: 21
	},
	"mandy" => {
		name: "Mandy Sinclair",
		age: 27
	},
	"georgeanne" => {
		name: "Georgeanne Senese",
		age: 22
	}
}

File.open('people.yaml','w') do |f|
	YAML.dump(people,f)
end