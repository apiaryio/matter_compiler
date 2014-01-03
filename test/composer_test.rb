require 'minitest/autorun'
require 'matter_compiler/composer'

class ComposerTest < Minitest::Unit::TestCase

  def test_guess_format
    # TODO:
    #assert_equal :yaml_ast, MatterCompiler::Composer.guess_format('test.yaml')
    #assert_equal :json_ast, MatterCompiler::Composer.guess_format('test.json')
    assert_equal :unknown_ast, MatterCompiler::Composer.guess_format('test.txt')
  end

end