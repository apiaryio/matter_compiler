require 'minitest/autorun'
require 'matter_compiler/blueprint'

class ResourceTest < Minitest::Unit::TestCase
  AST_HASH = {
    :name => "My Resource",
    :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n\n",
    :uriTemplate => "/my-resource/{id}",
    :model => nil,
    :parameters => nil,
    :headers => nil,
    :actions => nil
  }

  BLUEPRINT = \
%Q{## My Resource [/my-resource/{id}]
Lorem ipsum dolor sit amet, consectetur adipiscing elit.

}

  def test_from_ast_hash
    resource = MatterCompiler::Resource.new(ResourceTest::AST_HASH)
    assert_equal ResourceTest::AST_HASH[:name], resource.name
    assert_equal ResourceTest::AST_HASH[:description], resource.description
    assert_equal ResourceTest::AST_HASH[:uriTemplate], resource.uri_template
    assert_equal nil, resource.model
    assert_equal nil, resource.parameters
    assert_equal nil, resource.headers
    assert_equal nil, resource.actions
  end

  def test_serialize
    resource = MatterCompiler::Resource.new(ResourceTest::AST_HASH)
    assert_equal BLUEPRINT, resource.serialize
  end
end
