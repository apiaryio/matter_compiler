require 'yaml'
require 'json'
require 'matter_compiler/blueprint'
require 'object'

module MatterCompiler

  class BadInputException < Exception
  end

  class Composer

    # Read AST file
    def self.read_file(file)
      unless File.readable?(file)
        abort "Unable to read input ast file: #{file.inspect}"
      end
      input = File.read(file)
    end

    # Read AST from stdin.
    def self.read_stdin
      input = $stdin.read
    end

    # Parse format from string
    def self.parse_format(format)
      format.downcase!
      case format
      when "json"
        return :json_ast
      when "yml"
      when "yaml"
        return :yaml_ast
      else
        return :unknown_ast
      end
    end

    # Guess format from filename extension.
    def self.guess_format(file)
      extension = File.extname(file)
      if extension.length < 1
        return :unknown_ast
      end

      self.parse_format(extension[1..-1])
    end

    def self.parse_json(input)
      begin
        ast_hash = JSON.parse(input).deep_symbolize_keys
      rescue JSON::ParserError
        raise BadInputException, "Invalid JSON input"
      end
    end

    def self.parse_yaml(input)
      begin
        ast_hash = YAML.load(input).deep_symbolize_keys
      rescue Psych::SyntaxError
        raise BadInputException, "Invalid YAML input"
      end
      if not ast_hash.is_a?(Hash)
        raise BadInputException, "Invalid AST"
      end
      ast_hash
    end

    # Compose API Blueprint from an AST file.
    # Returns a string with composed API Blueprint.
    def self.compose(file = nil, format = nil, set_blueprint_format = false)
      # Read input
      input = nil
      if file.nil?
        input = self.read_stdin
      else
        input = self.read_file(file)
      end
      input = input.strip

      if input.blank?
        abort("Empty input")
      end

      # Parse input
      input_format = format ? format : self.guess_format(file)
      ast_hash = nil;
      begin
        case input_format
        when :json_ast
          ast_hash = self.parse_json(input)
        when :yaml_ast
          ast_hash = self.parse_yaml(input)
        else
          raise BadInputException, "Undefined input format"
        end
      rescue BadInputException => e
        abort(e.message)
      end

      # Check version of the AST
      unless Blueprint::SUPPORTED_VERSIONS.include?(ast_hash[Blueprint::VERSION_KEY].to_s)

        if ast_hash[Blueprint::VERSION_KEY].to_s == "1.0"
          puts "Use matter_compiler v0.4.0 to process AST media types prior AST v2.0"
        end

        abort("Invalid input: Unsupported AST version: '#{ast_hash[Blueprint::VERSION_KEY]}'\n")
      end

      # Process the AST hash
      blueprint = Blueprint.new(ast_hash)

      # TODO: use $stdout for now, add serialization options later
      puts blueprint.serialize(set_blueprint_format)
    end

  end

end
