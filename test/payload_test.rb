require 'minitest/autorun'
require 'matter_compiler/blueprint'
require_relative 'headers_test'

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
%Q{+ Model

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
    :headers => HeadersTest::AST_HASH,
    :body => "Hello\nWorld!\n",
    :schema => nil
  }

  AST_HASH_ABBREV = {
    :name => "200",
    :description => nil,
    :parameters => nil,
    :headers => HeadersTest::AST_HASH_CONTENT_ONLY,
    :body => "Hello\nWorld!\n",
    :schema => nil
  }

  AST_HASH_EMPTY = {
    :name => "204",
    :description => nil,
    :parameters => nil,
    :headers => nil,
    :body => nil,
    :schema => nil  
  }

  BLUEPRINT = \
%Q{+ Response 200 (text/plain)
#{HeadersTest::BLUEPRINT_NESTED_IGNORE_CONTENT}    + Body

            Hello
            World!

}

  BLUEPRINT_ABBREV = \
%Q{+ Response 200 (text/plain)

        Hello
        World!

}

  BLUEPRINT_EMPTY = \
%Q{+ Response 204

}

  def test_from_ast_hash
    response = MatterCompiler::Response.new(ResponseTest::AST_HASH)
    assert_equal ResponseTest::AST_HASH[:name], response.name
    assert_equal ResponseTest::AST_HASH[:description], response.description
    assert_equal nil, response.parameters

    assert_instance_of MatterCompiler::Headers, response.headers
    assert_instance_of Array, response.headers.collection
    assert_equal HeadersTest::AST_HASH.keys.length, response.headers.collection.length

    assert_equal ResponseTest::AST_HASH[:body], response.body
    assert_equal ResponseTest::AST_HASH[:schema], response.schema
  end

  def test_serialize
    # Full syntax
    response = MatterCompiler::Response.new(ResponseTest::AST_HASH)
    assert_equal ResponseTest::BLUEPRINT, response.serialize

    # Abbreviated syntax
    response = MatterCompiler::Response.new(ResponseTest::AST_HASH_ABBREV)
    assert_equal ResponseTest::BLUEPRINT_ABBREV, response.serialize

    # Empty response
    response = MatterCompiler::Response.new(ResponseTest::AST_HASH_EMPTY)
    assert_equal ResponseTest::BLUEPRINT_EMPTY, response.serialize
  end
end
