require 'minitest/autorun'
require 'matter_compiler/blueprint'
require_relative 'parameters_test'
require_relative 'headers_test'
require_relative 'transaction_example_test'

class ActionTest < Minitest::Test
  AST_HASH = {
    :name => "Into Action",
    :description => "Dolor sit amet\n\n",
    :method => "GET",
    :parameters => ParametersTest::AST_HASH,
    :examples => [TransactionExampleTest::AST_HASH]
  }

  BLUEPRINT = \
%Q{### Into Action [GET]
Dolor sit amet

#{ParametersTest::BLUEPRINT}#{TransactionExampleTest::BLUEPRINT}}

  def test_from_ast_hash
    action = MatterCompiler::Action.new(ActionTest::AST_HASH)
    assert_equal ActionTest::AST_HASH[:name], action.name
    assert_equal ActionTest::AST_HASH[:description], action.description
    assert_equal ActionTest::AST_HASH[:method], action.method
    
    assert_instance_of MatterCompiler::Parameters, action.parameters
    assert_instance_of Array, action.parameters.collection
    assert_equal ParametersTest::AST_HASH.length, action.parameters.collection.length

    assert_instance_of Array, action.examples
    assert_equal ActionTest::AST_HASH[:examples].length, action.examples.length
    assert action.examples.length > 0
    assert_instance_of MatterCompiler::TransactionExample, action.examples[0]
    assert_equal TransactionExampleTest::AST_HASH[:name], action.examples[0].name
  end

  def test_serialize
    action = MatterCompiler::Action.new(ActionTest::AST_HASH)
    assert_equal ActionTest::BLUEPRINT, action.serialize
  end
end
