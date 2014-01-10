require 'minitest/autorun'
require 'matter_compiler/blueprint'

class ParametersTest < Minitest::Unit::TestCase
  AST_HASH = {
    :id => {
      :description => "Lorem\nIpsum\n",
      :type => "number",
      :required => false,
      :default => "42",
      :example => "1000",
      :values => [ "42", "1000", "1AM4646" ]
    }
  }

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

  def test_from_ast_hash
    parameters = MatterCompiler::Parameters.new(ParametersTest::AST_HASH)
    assert_instance_of Array, parameters.collection
    assert_equal 1, parameters.collection.length
    assert_instance_of MatterCompiler::Parameter, parameters.collection[0]

    parameter = parameters.collection[0]
    assert_equal :id.to_s, parameter.name
    assert_equal ParametersTest::AST_HASH[:id][:description], parameter.description
    assert_equal ParametersTest::AST_HASH[:id][:type], parameter.type
    assert_equal :optional, parameter.use
    assert_equal ParametersTest::AST_HASH[:id][:default], parameter.default_value
    assert_equal ParametersTest::AST_HASH[:id][:example], parameter.example_value

    assert_instance_of Array, parameter.values
    assert_equal ParametersTest::AST_HASH[:id][:values].length, parameter.values.length
    assert_equal ParametersTest::AST_HASH[:id][:values][0], parameter.values[0]
    assert_equal ParametersTest::AST_HASH[:id][:values][1], parameter.values[1]
    assert_equal ParametersTest::AST_HASH[:id][:values][2], parameter.values[2]
  end

  def test_serialize
    parameters = MatterCompiler::Parameters.new(ParametersTest::AST_HASH)
    assert_equal ParametersTest::BLUEPRINT, parameters.serialize
  end
end
