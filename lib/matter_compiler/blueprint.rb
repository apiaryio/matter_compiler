module MatterCompiler
  
  # The classes in this document should be 1:1 with relevant Snow Crash 
  # counterparts (https://github.com/apiaryio/snowcrash/blob/master/src/Blueprint.h)
  # until Matter Compiler becomes a wrapper for Snow Crash.

  # Blueprint Node
  class BlueprintNode
    def initialize(hash = nil)
      load_ast_hash!(hash) if hash
    end

    # Load AST has into block
    def load_ast_hash!(hash)
    end

    # Serialize block to a Markdown string
    def serialize
    end
  end

  # Named Blueprint Node
  class NamedBlueprintNode < BlueprintNode
    def load_ast_hash!(hash)
      @name = hash[:name]
      @description = hash[:description]
    end
  end

  class Metadata < BlueprintNode
    attr_accessor :collection

    def load_ast_hash!(hash)
      return if hash.empty?

      @collection = Array.new
      hash.each do |key, value_hash|
        @collection << Hash[key, value_hash[:value]]
      end
    end

    def serialize
      buffer = ""
      collection.each do |hash|
        buffer << "#{hash.keys[0]}: #{hash.values[0]}\n"
      end
      buffer
    end
  end

  class Parameter < NamedBlueprintNode
    attr_accessor :name
    attr_accessor :description
    attr_accessor :type
    attr_accessor :use
    attr_accessor :default_value
    attr_accessor :example_value
    attr_accessor :values
  end

  class Payload < NamedBlueprintNode
    attr_accessor :name
    attr_accessor :description
    attr_accessor :parameters
    attr_accessor :headers
    attr_accessor :body
    attr_accessor :schema

    def load_ast_hash!(hash)
      super(hash)

      @body = hash[:body]
      @schema = hash[:schema]
      # TODO: Parameters, Headers
    end

    def serialize
      # Name is serialized in Payload successors
      buffer = ""

      unless @description.blank?
        @description.each_line { |line| buffer << "  #{line}" }
        buffer << "\n"
      end

      unless @body.blank?
        buffer << "    + Body\n\n"
        @body.each_line { |line| buffer << "            #{line}" }
        buffer << "\n"
      end

      unless @schema.blank?
        buffer << "    + Schema\n\n"
        @schema.each_line { |line| buffer << "            #{line}" }
        buffer << "\n"
      end

      # TODO: Parameters, Headers
      buffer
    end    
  end

  class Model < Payload
    def serialize
      buffer = ""
      buffer << "+ Model"
      buffer << " #{@name}" unless @name.blank?
      buffer << "\n\n"
      buffer << super
    end
  end

  class Request < Payload
    def serialize
      buffer = ""
      buffer << "+ Request"
      buffer << " #{@name}" unless @name.blank?
      buffer << "\n\n"
      buffer << super
    end    
  end

  class Response < Payload;
    def serialize
      buffer = ""
      buffer << "+ Response"
      buffer << " #{@name}" unless @name.blank?
      buffer << "\n\n"
      buffer << super
    end    
  end

  class TransactionExample < NamedBlueprintNode
    attr_accessor :name
    attr_accessor :description
    attr_accessor :requests
    attr_accessor :responses
  end

  class Action < NamedBlueprintNode
    attr_accessor :method
    attr_accessor :name
    attr_accessor :description
    attr_accessor :parameters
    attr_accessor :headers
    attr_accessor :examples
  end
  
  class Resource < NamedBlueprintNode
    attr_accessor :uri_template
    attr_accessor :name
    attr_accessor :description
    attr_accessor :model
    attr_accessor :parameters
    attr_accessor :headers
    attr_accessor :actions

    def load_ast_hash!(hash)
      super(hash)

      @uri_template = hash[:uriTemplate]      
      # TODO: Load Model, Parameters, Headers, Actions
    end

    def serialize
      buffer = ""
      if @name.blank?
        buffer << "## #{@uri_template}\n"
      else
        buffer << "## #{@name} [#{@uri_template}]\n"
      end

      buffer << "#{@description}" unless @description.blank?

      # TODO: Serialize Model, Parameters, Headers, Actions
      buffer
    end
  end

  class ResourceGroup < NamedBlueprintNode
    attr_accessor :name
    attr_accessor :description
    attr_accessor :resources

    def load_ast_hash!(hash)
      super(hash)

      unless hash[:resources].empty?
        @resources = Array.new
        hash[:resources].each { |resource_hash| @resources << Resource.new(resource_hash) }
      end
    end

    def serialize
      buffer = ""
      buffer << "# Group #{@name}\n" unless @name.blank?
      buffer << "#{@description}" unless @description.blank?

      @resources.each { |resource| buffer << resource.serialize } unless @resources.nil?
      buffer
    end
  end

  class Blueprint < NamedBlueprintNode
    attr_accessor :metadata
    attr_accessor :name
    attr_accessor :description
    attr_accessor :resource_groups

    def load_ast_hash!(hash)
      super(hash)
      
      # Load Metadata
      unless hash[:metadata].empty?
        @metadata = Metadata.new(hash[:metadata])
      end
      
      # Load Resource Groups
      unless hash[:resourceGroups].empty?
        @resource_groups = Array.new
        hash[:resourceGroups].each { |group_hash| @resource_groups << ResourceGroup.new(group_hash) }
      end
    end

    def serialize
      buffer = ""
      buffer << "#{@metadata.serialize}\n" unless @metadata.nil?      
      buffer << "# #{@name}\n" unless @name.blank?
      buffer << "#{@description}" unless @description.blank?

      @resource_groups.each { |group| buffer << group.serialize } unless @resource_groups.nil?
      buffer
    end
  end
end
