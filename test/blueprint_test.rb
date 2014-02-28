require 'minitest/autorun'
require 'matter_compiler/blueprint'
require_relative 'resource_group_test'
require_relative 'metadata_test'

class BlueprintTest < Minitest::Test
  AST_HASH = {
    :_version => 1.0,
    :metadata => MetadataTest::AST_HASH,
    :name => "My API",
    :description => "Lorem Ipsum\n\n",
    :resourceGroups => [ ResourceGroupTest::AST_HASH ]
  }

  BLUEPRINT = \
%Q{#{MetadataTest::BLUEPRINT}# My API
Lorem Ipsum

#{ResourceGroupTest::BLUEPRINT}}

  def test_from_ast_hash
    blueprint = MatterCompiler::Blueprint.new(BlueprintTest::AST_HASH)

    assert_equal BlueprintTest::AST_HASH[:name], blueprint.name
    assert_equal BlueprintTest::AST_HASH[:description], blueprint.description
    
    assert_instance_of Array, blueprint.resource_groups
    assert_equal BlueprintTest::AST_HASH[:resourceGroups].length, blueprint.resource_groups.length
    assert_equal ResourceGroupTest::AST_HASH[:name], blueprint.resource_groups[0].name

    assert_instance_of MatterCompiler::Metadata, blueprint.metadata
    assert_instance_of Array, blueprint.metadata.collection
    assert_equal BlueprintTest::AST_HASH[:metadata].length, blueprint.metadata.collection.length
    assert_equal BlueprintTest::AST_HASH[:metadata][0][:name], blueprint.metadata.collection[0].keys[0].to_s
  end

  def test_serialize
    blueprint = MatterCompiler::Blueprint.new(BlueprintTest::AST_HASH)
    assert_equal BlueprintTest::BLUEPRINT, blueprint.serialize
    
    #puts "\n\n>>>\n#{blueprint.serialize}"
  end
end
