require 'minitest/autorun'
require 'matter_compiler/blueprint'
require_relative 'resource_group_test'

class BlueprintTest < Minitest::Unit::TestCase

  AST_HASH = {
    :_version => 1.0,
    :metadata => nil,
    :name => "My API",
    :description => "Lorem Ipsum\n\n",
    :resourceGroups => [ ResourceGroupTest::AST_HASH ]
  }

  BLUEPRINT = \
%Q{# My API
Lorem Ipsum

#{ResourceGroupTest::BLUEPRINT}}

  def test_from_ast_hash
    blueprint = MatterCompiler::Blueprint.new(BlueprintTest::AST_HASH)

    assert_equal BlueprintTest::AST_HASH[:name], blueprint.name
    assert_equal BlueprintTest::AST_HASH[:description], blueprint.description
    
    assert_instance_of Array, blueprint.resource_groups
    assert_equal BlueprintTest::AST_HASH[:resourceGroups].length, blueprint.resource_groups.length
    assert_equal ResourceGroupTest::AST_HASH[:name], blueprint.resource_groups[0].name

    # TODO: Metadata
    assert_equal nil, blueprint.metadata
  end

  def test_serialize
    blueprint = MatterCompiler::Blueprint.new(BlueprintTest::AST_HASH)
    assert_equal BLUEPRINT, blueprint.serialize
  end

end