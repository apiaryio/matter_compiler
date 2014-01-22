require 'minitest/autorun'
require 'matter_compiler/composer'

class ComposerTest < Minitest::Test
  def test_guess_format
    assert_equal :yaml_ast, MatterCompiler::Composer.guess_format('test.yaml')
    assert_equal :json_ast, MatterCompiler::Composer.guess_format('test.json')
    assert_equal :unknown_ast, MatterCompiler::Composer.guess_format('test.txt')
  end
end