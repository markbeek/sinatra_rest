require 'sinatra'
require 'json'
require 'yaml'

puts "starting people service"

people = {}
File.open('people.yaml') do |f|
	people = YAML.load(f)
end

before do
	content_type "application/json"	#both browsers treat this as a download, have to open in separate application 
	#content_type :txt	#this is rendered directly in the browser
end

get '/user/:id' do
	user_id = params[:id]
	user_data = people[user_id]
	user_json = user_data ? JSON.generate(user_data) : JSON.generate({:no_user => "no person found with user id #{user_id}"})
	user_json
end

puts "service started"