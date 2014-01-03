module MatterCompiler
  
  class Composer
  
    # Read YAML AST file.
    def self.load_YAML(filename)
    end 

    # Read JSON AST file.
    def self.load_JSON(filename)
    end

    # Read AST from stdin.
    def self.read_stdin()
    end

    # Guess format from filename extension.
    def self.guess_format(filename)
      :unknown_ast
    end

    # Compose API Blueprint from an AST file.
    # Returns a string with composed API Blueprint.
    def self.compose(file = nil, format = nil)
      puts "Compose file: #{file} with format: #{format}"
    end
  
  end

end
