require 'minitest/autorun'
require 'matter_compiler/blueprint'
require_relative 'resource_test'

class ResourceGroupTest < Minitest::Unit::TestCase
  AST_HASH = {
    :name => "My Resource Group",
    :description => "Lorem Ipsum at [Apiary](http://apiary.io)\n\n",
    :resources => [ ResourceTest::AST_HASH ]
  }

  BLUEPRINT = \
%Q{# Group My Resource Group
Lorem Ipsum at [Apiary](http://apiary.io)

#{ResourceTest::BLUEPRINT}}

  def test_from_ast_hash
    resource_group = MatterCompiler::ResourceGroup.new(ResourceGroupTest::AST_HASH)
    assert_equal ResourceGroupTest::AST_HASH[:name], resource_group.name
    assert_equal ResourceGroupTest::AST_HASH[:description], resource_group.description
    
    assert_instance_of Array, resource_group.resources
    assert_equal ResourceGroupTest::AST_HASH[:resources].length, resource_group.resources.length
    assert_equal ResourceTest::AST_HASH[:name], resource_group.resources[0].name
  end

  def test_serialize
    resource_group = MatterCompiler::ResourceGroup.new(ResourceGroupTest::AST_HASH)
    assert_equal BLUEPRINT, resource_group.serialize
  end
end
