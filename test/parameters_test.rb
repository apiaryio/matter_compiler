require 'minitest/autorun'
require 'matter_compiler/blueprint'

class ParametersTest < Minitest::Test
  AST_HASH = [
    {
      :name => "id",
      :description => "Lorem\nIpsum\n",
      :type => "number",
      :required => false,
      :default => "42",
      :example => "1000",
      :values => [ 
        { :value => "42" }, 
        { :value => "1000"}, 
        { :value => "1AM4646"}
      ]
    }
  ]

  AST_HASH_MANY = [
    {
      :name => "id",
      :description => "Lorem",
      :type => nil,
      :required => true,
      :default => nil,
      :example => nil,
      :values => nil
    },
    {
      :name => "search",
      :description => "Ipsum",
      :type => nil,
      :required => true,
      :default => nil,
      :example => nil,
      :values => nil
    }    
  ]

  BLUEPRINT = \
%Q{+ Parameters
    + id = `42` (number, optional, `1000`)

        Lorem
        Ipsum

        + Values
            + `42`
            + `1000`
            + `1AM4646`

}

  BLUEPRINT_MANY = \
%Q{+ Parameters
    + id ... Lorem
    + search ... Ipsum

}

  def test_from_ast_hash
    parameters = MatterCompiler::Parameters.new(ParametersTest::AST_HASH)
    assert_instance_of Array, parameters.collection
    assert_equal 1, parameters.collection.length
    assert_instance_of MatterCompiler::Parameter, parameters.collection[0]

    parameter = parameters.collection[0]
    assert_equal :id.to_s, parameter.name
    assert_equal ParametersTest::AST_HASH[0][:description], parameter.description
    assert_equal ParametersTest::AST_HASH[0][:type], parameter.type
    assert_equal :optional, parameter.use
    assert_equal ParametersTest::AST_HASH[0][:default], parameter.default_value
    assert_equal ParametersTest::AST_HASH[0][:example], parameter.example_value

    assert_instance_of Array, parameter.values
    assert_equal ParametersTest::AST_HASH[0][:values].length, parameter.values.length
    assert_equal ParametersTest::AST_HASH[0][:values][0][:value], parameter.values[0]
    assert_equal ParametersTest::AST_HASH[0][:values][1][:value], parameter.values[1]
    assert_equal ParametersTest::AST_HASH[0][:values][2][:value], parameter.values[2]
  end

  def test_serialize
    parameters = MatterCompiler::Parameters.new(ParametersTest::AST_HASH)
    assert_equal ParametersTest::BLUEPRINT, parameters.serialize

    parameters = MatterCompiler::Parameters.new(ParametersTest::AST_HASH_MANY)
    assert_equal ParametersTest::BLUEPRINT_MANY, parameters.serialize    
  end
end
