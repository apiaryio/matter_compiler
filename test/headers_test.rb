require 'minitest/autorun'
require 'matter_compiler/blueprint'

class HeadersTest < Minitest::Unit::TestCase
  AST_HASH = {
    :'X-Header' => {
      :value => "1"      
    }
  }

  BLUEPRINT = \
%Q{+ Headers

        X-Header: 1

}

  BLUEPRINT_NESTED = \
%Q{    + Headers

            X-Header: 1

}

  def test_from_ast_hash
    headers = MatterCompiler::Headers.new(HeadersTest::AST_HASH)
    assert_equal 1, headers.collection.length
    assert_instance_of Hash, headers.collection[0]
    assert_equal :'X-Header', headers.collection[0].keys[0]
    assert_equal "1", headers.collection[0][:'X-Header']
  end

  def test_serialize
    headers = MatterCompiler::Headers.new(HeadersTest::AST_HASH)
    assert_equal HeadersTest::BLUEPRINT, headers.serialize
  end
end
