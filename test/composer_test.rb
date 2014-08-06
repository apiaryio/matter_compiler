require 'tempfile'
require 'stringio'
require 'minitest/autorun'
require 'matter_compiler/composer'


class ComposerTest < Minitest::Test

  def test_guess_format
    assert_equal :yaml_ast, MatterCompiler::Composer.guess_format('test.yaml')
    assert_equal :json_ast, MatterCompiler::Composer.guess_format('test.json')
    assert_equal :unknown_ast, MatterCompiler::Composer.guess_format('test.txt')
  end

  def test_empty_file_input
    file = Tempfile.new('test.json')
    file.close

    stderr = StringIO.new
    $stderr = stderr

    begin
      MatterCompiler::Composer.compose(file.path, :json_ast)
    rescue SystemExit
    ensure
      assert_equal "Empty input\n", stderr.string

      file.unlink
      $stderr = STDERR
    end
  end

  def test_whitespace_only_file_input
    file = Tempfile.new('test.json')
    file.write("\n\n\n\n\n")
    file.close

    stderr = StringIO.new
    $stderr = stderr

    begin
      MatterCompiler::Composer.compose(file.path, :json_ast)
    rescue SystemExit
    ensure
      assert_equal "Empty input\n", stderr.string

      file.unlink
      $stderr = STDERR
    end
  end

  def test_corrupted_json_input
    file = Tempfile.new('test.json')
    file.write("{\n:-(")
    file.close

    stderr = StringIO.new
    $stderr = stderr

    begin
      MatterCompiler::Composer.compose(file.path, :json_ast)
    rescue SystemExit
    ensure
      assert_equal "Invalid JSON input\n", stderr.string

      file.unlink
      $stderr = STDERR
    end
  end

  def test_corrupted_yaml_input
    file = Tempfile.new('test.yaml')
    file.write("@@@@@\n:-(")
    file.close

    stderr = StringIO.new
    $stderr = stderr

    begin
      MatterCompiler::Composer.compose(file.path, :yaml_ast)
    rescue SystemExit
    ensure
      assert_equal "Invalid YAML input\n", stderr.string

      file.unlink
      $stderr = STDERR
    end
  end

end
