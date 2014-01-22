require 'minitest/autorun'
require 'matter_compiler/blueprint'
require_relative 'payload_test'

class TransactionExampleTest < Minitest::Test
  AST_HASH = {
    :name => "",
    :description => "",
    :requests => [RequestTest::AST_HASH],
    :responses => [ResponseTest::AST_HASH]
  }

  BLUEPRINT = \
%Q{#{RequestTest::BLUEPRINT}#{ResponseTest::BLUEPRINT}}

  def test_from_ast_hash
    transaction_example = MatterCompiler::TransactionExample.new(TransactionExampleTest::AST_HASH)
    assert_equal TransactionExampleTest::AST_HASH[:name], transaction_example.name
    assert_equal TransactionExampleTest::AST_HASH[:description], transaction_example.description
    
    assert_instance_of Array, transaction_example.requests
    assert_equal TransactionExampleTest::AST_HASH[:requests].length, transaction_example.requests.length
    assert transaction_example.requests.length > 0
    assert_instance_of MatterCompiler::Request, transaction_example.requests[0]
    assert_equal RequestTest::AST_HASH[:name], transaction_example.requests[0].name

    assert_instance_of Array, transaction_example.responses
    assert_equal TransactionExampleTest::AST_HASH[:responses].length, transaction_example.responses.length
    assert transaction_example.responses.length > 0
    assert_instance_of MatterCompiler::Response, transaction_example.responses[0]
    assert_equal ResponseTest::AST_HASH[:name], transaction_example.responses[0].name
  end

  def test_serialize
    action = MatterCompiler::TransactionExample.new(TransactionExampleTest::AST_HASH)
    assert_equal TransactionExampleTest::BLUEPRINT, action.serialize
  end
end
