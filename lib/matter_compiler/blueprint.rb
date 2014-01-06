module MatterCompiler
  
  # The classes in this document should be 1:1 with relevant Snow Crash 
  # counterparts (https://github.com/apiaryio/snowcrash/blob/master/src/Blueprint.h)
  # until Matter Compiler becomes a wrapper for Snow Crash.

  class Parameter
    attr_accessor :name
    attr_accessor :description
    attr_accessor :type
    attr_accessor :use
    attr_accessor :default_value
    attr_accessor :example_value
    attr_accessor :values
  end

  class Payload
    attr_accessor :name
    attr_accessor :description
    attr_accessor :parameters
    attr_accessor :headers
    attr_accessor :body
    attr_accessor :schema
  end

  class TransactionExample
    attr_accessor :name
    attr_accessor :description
    attr_accessor :requests
    attr_accessor :responses
  end

  class Action
    attr_accessor :method
    attr_accessor :name
    attr_accessor :description
    attr_accessor :parameters
    attr_accessor :headers
    attr_accessor :examples
  end
  
  class Resource
    attr_accessor :uri_template
    attr_accessor :name
    attr_accessor :description
    attr_accessor :model
    attr_accessor :parameters
    attr_accessor :headers
    attr_accessor :actions
  end

  class ResourceGroup
    attr_accessor :name
    attr_accessor :description
    attr_accessor :resources
  end

  class Blueprint
    attr_accessor :metadata
    attr_accessor :name
    attr_accessor :description
    attr_accessor :resourceGroups

    def initialize(hash = nil)
      load_ast_hash!(hash) if hash
    end

    def load_ast_hash!(hash)
      # TODO: Load Metadata and Resource Groups
      @metadata = nil
      @name = hash[:name]
      @description = hash[:description]
      @resourceGroups = nil
    end

    def serialize
      # TODO: Serialize Metadata and Resource Groups      
      buffer = ""
      buffer << "# #{@name}\n" unless @name.blank?
      buffer << "#{@description}\n" unless @description.blank?
      buffer
    end

  end

end
