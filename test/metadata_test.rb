require 'minitest/autorun'
require 'matter_compiler/blueprint'

class MetadataTest < Minitest::Test
  AST_HASH = [
    {
      :name => "FORMAT",
      :value => "1A"
    }
  ]

  BLUEPRINT = \
%Q{FORMAT: 1A

}

  def test_from_ast_hash
    metadata = MatterCompiler::Metadata.new(MetadataTest::AST_HASH)
    assert_equal 1, metadata.collection.length
    assert_instance_of Hash, metadata.collection[0]
    assert_equal :FORMAT, metadata.collection[0].keys[0]
    assert_equal "1A", metadata.collection[0][:FORMAT]
  end

  def test_empty_metadata
    metadata = MatterCompiler::Metadata.new([{}])
  end

  def test_serialize
    metadata = MatterCompiler::Metadata.new(MetadataTest::AST_HASH)
    assert_equal MetadataTest::BLUEPRINT, metadata.serialize
  end
end
