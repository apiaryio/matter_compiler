require 'minitest/autorun'
require 'matter_compiler/blueprint'

class ResourceGroupTest < Minitest::Unit::TestCase

  AST_HASH = {
    :name => "My Resource Group",
    :description => "Lorem Ipsum at [Apiary](http://apiary.io)\n",
    :resources => nil
  }

  BLUEPRINT = \
%Q{# Group My Resource Group
Lorem Ipsum at [Apiary](http://apiary.io)
}

  def test_from_ast_hash
    resource_group = MatterCompiler::ResourceGroup.new(ResourceGroupTest::AST_HASH)
    assert_equal ResourceGroupTest::AST_HASH[:name], resource_group.name
    assert_equal ResourceGroupTest::AST_HASH[:description], resource_group.description
    assert_equal nil, resource_group.resources
  end

  def test_serialize
    resource_group = MatterCompiler::ResourceGroup.new(ResourceGroupTest::AST_HASH)
    assert_equal BLUEPRINT, resource_group.serialize
  end

end
