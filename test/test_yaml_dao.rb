#run raw with
#ruby -I. test/test_yaml_dao.rb

#run rake with:
#rake test

require 'test/unit'
require_relative '../lib/dao/yaml_dao.rb'

class YamlDaoTest < Test::Unit::TestCase

	def test_add_person
		assert(1==1)
	end

end