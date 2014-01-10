require 'minitest/autorun'
require 'matter_compiler/blueprint'
require_relative 'action_test'
require_relative 'payload_test'
require_relative 'parameters_test'
require_relative 'headers_test'

class ResourceTest < Minitest::Unit::TestCase
  AST_HASH = {
    :name => "My Resource",
    :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n\n",
    :uriTemplate => "/my-resource/{id}",
    :model => ModelTest::AST_HASH,
    :parameters => ParametersTest::AST_HASH,
    :headers => HeadersTest::AST_HASH,
    :actions => [ActionTest::AST_HASH]
  }

  BLUEPRINT = \
%Q{## My Resource [/my-resource/{id}]
Lorem ipsum dolor sit amet, consectetur adipiscing elit.

#{ModelTest::BLUEPRINT}#{ParametersTest::BLUEPRINT}#{HeadersTest::BLUEPRINT}#{ActionTest::BLUEPRINT}}

  def test_from_ast_hash
    resource = MatterCompiler::Resource.new(ResourceTest::AST_HASH)
    assert_equal ResourceTest::AST_HASH[:name], resource.name
    assert_equal ResourceTest::AST_HASH[:description], resource.description
    assert_equal ResourceTest::AST_HASH[:uriTemplate], resource.uri_template
    
    assert_instance_of MatterCompiler::Model, resource.model
    assert_equal ModelTest::AST_HASH[:name], resource.model.name

    assert_instance_of MatterCompiler::Parameters, resource.parameters
    assert_instance_of Array, resource.parameters.collection
    assert_equal ParametersTest::AST_HASH.keys.length, resource.parameters.collection.length

    assert_instance_of MatterCompiler::Headers, resource.headers
    assert_instance_of Array, resource.headers.collection
    assert_equal HeadersTest::AST_HASH.keys.length, resource.headers.collection.length

    assert_instance_of Array, resource.actions
    assert_equal ResourceTest::AST_HASH[:actions].length, resource.actions.length
    assert ResourceTest::AST_HASH[:actions].length > 0
    assert_instance_of MatterCompiler::Action, resource.actions[0]
    assert_equal ActionTest::AST_HASH[:name], resource.actions[0].name
  end

  def test_serialize
    resource = MatterCompiler::Resource.new(ResourceTest::AST_HASH)
    assert_equal ResourceTest::BLUEPRINT, resource.serialize
  end
end
