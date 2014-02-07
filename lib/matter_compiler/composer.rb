require 'yaml'
require 'json'
require 'matter_compiler/blueprint'
require 'object'

module MatterCompiler

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

      if input.blank?
        puts "Empty input"
        exit
      end

      # Parse input
      input_format = format ? format : self.guess_format(file)
      ast_hash = nil;
      case input_format
      when :json_ast
        ast_hash = JSON.parse(input).deep_symbolize_keys
      when :yaml_ast
        ast_hash = YAML.load(input).deep_symbolize_keys
      else
        abort "Undefined input format"
      end

      # Check version of the AST
      unless Blueprint::SUPPORTED_VERSIONS.include?(ast_hash[Blueprint::VERSION_KEY].to_s)
        abort("unsupported AST version: '#{ast_hash[Blueprint::VERSION_KEY]}'\n")
      end

      # Process the AST hash
      blueprint = Blueprint.new(ast_hash)

      # TODO: use $stdout for now, add serialization options later
      puts blueprint.serialize(set_blueprint_format)
    end
  
  end

end
