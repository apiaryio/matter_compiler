require 'minitest/autorun'
require 'matter_compiler/blueprint'

#
# Payload test consists of testing Model, Request and Response
# with model test used as an archetype for payload.
#

class ModelTest < Minitest::Unit::TestCase
  AST_HASH = {
    :name => "My Resource",
    :description => "Lorem ipsum dolor sit amet.\n",
    :parameters => nil,
    :headers => nil,
    :body => "{ \"message\": \"Hello World\" }\n",
    :schema => "{ \"$schema\": \"http://json-schema.org/draft-03/schema\" }\n"
  }

  BLUEPRINT = \
%Q{+ Model My Resource

  Lorem ipsum dolor sit amet.

    + Body

            { \"message\": \"Hello World\" }

    + Schema

            { \"$schema\": \"http://json-schema.org/draft-03/schema\" }

}

  def test_from_ast_hash
    model = MatterCompiler::Model.new(ModelTest::AST_HASH)
    assert_equal ModelTest::AST_HASH[:name], model.name
    assert_equal ModelTest::AST_HASH[:description], model.description
    assert_equal nil, model.parameters
    assert_equal nil, model.headers
    assert_equal ModelTest::AST_HASH[:body], model.body
    assert_equal ModelTest::AST_HASH[:schema], model.schema
  end

  def test_serialize
    model = MatterCompiler::Model.new(ModelTest::AST_HASH)
    assert_equal ModelTest::BLUEPRINT, model.serialize
  end
end

class RequestTest < Minitest::Unit::TestCase
  AST_HASH = {
    :name => "Name",
    :description => "Lorem\nIpsum\n",
    :parameters => nil,
    :headers => nil,
    :body => "Hello World!\n",
    :schema => nil
  }

  BLUEPRINT = \
%Q{+ Request Name

  Lorem
  Ipsum

    + Body

            Hello World!

}

  def test_from_ast_hash
    request = MatterCompiler::Request.new(RequestTest::AST_HASH)
    assert_equal RequestTest::AST_HASH[:name], request.name
    assert_equal RequestTest::AST_HASH[:description], request.description
    assert_equal nil, request.parameters
    assert_equal nil, request.headers
    assert_equal RequestTest::AST_HASH[:body], request.body
    assert_equal RequestTest::AST_HASH[:schema], request.schema
  end

  def test_serialize
    request = MatterCompiler::Request.new(RequestTest::AST_HASH)
    assert_equal RequestTest::BLUEPRINT, request.serialize
  end
end

class ResponseTest < Minitest::Unit::TestCase
  AST_HASH = {
    :name => "200",
    :description => nil,
    :parameters => nil,
    :headers => nil,
    :body => "Hello\nWorld!\n",
    :schema => nil
  }

  BLUEPRINT = \
%Q{+ Response 200

    + Body

            Hello
            World!

}

  def test_from_ast_hash
    response = MatterCompiler::Response.new(ResponseTest::AST_HASH)
    assert_equal ResponseTest::AST_HASH[:name], response.name
    assert_equal ResponseTest::AST_HASH[:description], response.description
    assert_equal nil, response.parameters
    assert_equal nil, response.headers
    assert_equal ResponseTest::AST_HASH[:body], response.body
    assert_equal ResponseTest::AST_HASH[:schema], response.schema
  end

  def test_serialize
    response = MatterCompiler::Response.new(ResponseTest::AST_HASH)
    assert_equal ResponseTest::BLUEPRINT, response.serialize
  end
end
