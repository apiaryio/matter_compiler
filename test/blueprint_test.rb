require 'minitest/autorun'
require 'matter_compiler/blueprint'

class BlueprintTest < Minitest::Unit::TestCase

  def test_from_ast_hash
    ast_hash = {
      :_version => 1.0,
      :metadata => nil,
      :name => "API Name",
      :description => "Lorem Ipsum",
      :resourceGroups => nil
    }

    blueprint = MatterCompiler::Blueprint.new(ast_hash)
  
    assert_equal "API Name", blueprint.name
    assert_equal "Lorem Ipsum", blueprint.description
    assert_equal nil, blueprint.resourceGroups
    assert_equal nil, blueprint.metadata
  end

  def test_serialize
    blueprint = MatterCompiler::Blueprint.new
    blueprint.name = "API Name"
    blueprint.description = "Lorem Ipsum"

    expected_blueprint = \
%q{# API Name
Lorem Ipsum
}
    assert_equal expected_blueprint, blueprint.serialize()
  end

end