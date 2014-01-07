module MatterCompiler
  
  # The classes in this document should be 1:1 with relevant Snow Crash 
  # counterparts (https://github.com/apiaryio/snowcrash/blob/master/src/Blueprint.h)
  # until Matter Compiler becomes a wrapper for Snow Crash.

  class BlueprintObject

    def initialize(hash = nil)
      load_ast_hash!(hash) if hash
    end

    # Load AST has into block
    def load_ast_hash!(hash)
      @name = hash[:name]
      @description = hash[:description]
    end

    # Serialize block to a Markdown string
    def serialize
    end
  end

  class Parameter < BlueprintObject
    attr_accessor :name
    attr_accessor :description
    attr_accessor :type
    attr_accessor :use
    attr_accessor :default_value
    attr_accessor :example_value
    attr_accessor :values
  end

  class Payload < BlueprintObject
    attr_accessor :name
    attr_accessor :description
    attr_accessor :parameters
    attr_accessor :headers
    attr_accessor :body
    attr_accessor :schema
  end

  class TransactionExample < BlueprintObject
    attr_accessor :name
    attr_accessor :description
    attr_accessor :requests
    attr_accessor :responses
  end

  class Action < BlueprintObject
    attr_accessor :method
    attr_accessor :name
    attr_accessor :description
    attr_accessor :parameters
    attr_accessor :headers
    attr_accessor :examples
  end
  
  class Resource < BlueprintObject
    attr_accessor :uri_template
    attr_accessor :name
    attr_accessor :description
    attr_accessor :model
    attr_accessor :parameters
    attr_accessor :headers
    attr_accessor :actions
  end

  class ResourceGroup < BlueprintObject
    attr_accessor :name
    attr_accessor :description
    attr_accessor :resources

    def load_ast_hash!(hash)
      super(hash)

      # TODO: Load Resources      
    end

    def serialize
      buffer = ""

      # Group Name
      buffer << "# Group #{@name}\n" unless @name.blank?

      # Group Description
      buffer << "#{@description}" unless @description.blank?

      # Delimiter
      #buffer << "\n" unless buffer.empty?

      # TODO: Serialize Resources      

      buffer
    end    

  end

  class Blueprint < BlueprintObject
    attr_accessor :metadata
    attr_accessor :name
    attr_accessor :description
    attr_accessor :resource_groups

    def load_ast_hash!(hash)
      super(hash)
      
      # TODO: Load Metadata
      @metadata = nil
      
      # Load Resource Groups
      unless hash[:resourceGroups].empty?
        @resource_groups = Array.new
        hash[:resourceGroups].each { |group_hash| @resource_groups << ResourceGroup.new(group_hash) }
      end
    end

    def serialize
      buffer = ""

      # TODO: Serialize Metadata

      # API Name
      buffer << "# #{@name}\n" unless @name.blank?

      # API Description
      buffer << "#{@description}" unless @description.blank?

      # Delimiter
      #buffer << "\n" unless buffer.empty?

      # Resource Groups
      @resource_groups.each { |group| buffer << group.serialize } unless @resource_groups.nil?

      buffer
    end

  end

end
