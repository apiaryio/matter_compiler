require 'minitest/autorun'
require 'matter_compiler/blueprint'

class HeadersTest < Minitest::Test
  AST_HASH = {
    :'X-Header' => {
      :value => "1"      
    },
    :'Content-Type' => {
      :value => "text/plain"
    }
  }

  AST_HASH_CONTENT_ONLY = {
    :'Content-Type' => {
      :value => "text/plain"
    }
  }  

  BLUEPRINT = \
%Q{+ Headers

        X-Header: 1
        Content-Type: text/plain

}

  BLUEPRINT_IGNORE_CONTENT = \
%Q{+ Headers

        X-Header: 1

}

  BLUEPRINT_CONTENT_ONLY = \
%Q{+ Headers

        Content-Type: text/plain

}

  BLUEPRINT_IGNORE_CONTENT_CONTENT_ONLY = %Q{}

  BLUEPRINT_NESTED_IGNORE_CONTENT = \
%Q{    + Headers

            X-Header: 1

}

  def test_from_ast_hash
    headers = MatterCompiler::Headers.new(HeadersTest::AST_HASH)
    assert_equal 2, headers.collection.length

    assert_instance_of Hash, headers.collection[0]
    assert_equal :'X-Header', headers.collection[0].keys[0]
    assert_equal "1", headers.collection[0][:'X-Header']

    assert_instance_of Hash, headers.collection[1]
    assert_equal :'Content-Type', headers.collection[1].keys[0]
    assert_equal "text/plain", headers.collection[1][:'Content-Type']

    assert_equal "text/plain", headers.content_type    
  end

  def test_serialize
    headers = MatterCompiler::Headers.new(HeadersTest::AST_HASH)
    assert_equal HeadersTest::BLUEPRINT, headers.serialize(0)
    assert_equal HeadersTest::BLUEPRINT_IGNORE_CONTENT, headers.serialize(0, [MatterCompiler::Headers::CONTENT_TYPE_HEADER_KEY])

    headers = MatterCompiler::Headers.new(HeadersTest::AST_HASH_CONTENT_ONLY)
    assert_equal HeadersTest::BLUEPRINT_CONTENT_ONLY, headers.serialize(0)
    assert_equal HeadersTest::BLUEPRINT_IGNORE_CONTENT_CONTENT_ONLY, headers.serialize(0, [MatterCompiler::Headers::CONTENT_TYPE_HEADER_KEY])
  end
end
