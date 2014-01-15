module MatterCompiler
  
  # The classes in this document should be 1:1 with relevant Snow Crash 
  # counterparts (https://github.com/apiaryio/snowcrash/blob/master/src/Blueprint.h)
  # until Matter Compiler becomes a wrapper for Snow Crash.

  #
  # Blueprint AST node
  #
  class BlueprintNode
    ONE_INDENTATION_LEVEL = "    "

    def initialize(hash = nil)
      load_ast_hash!(hash) if hash
    end

    # Load AST has into block
    def load_ast_hash!(hash)
    end

    # Serialize block to a Markdown string
    def serialize(level = 0)
    end
  end

  #
  # Named Blueprint AST node
  #
  class NamedBlueprintNode < BlueprintNode
    def load_ast_hash!(hash)
      @name = hash[:name]
      @description = hash[:description]
    end
  end

  #
  # Key-value collection
  #
  class KeyValueCollection < BlueprintNode
    attr_accessor :collection

    def load_ast_hash!(hash)
      return if hash.empty?

      @collection = Array.new
      hash.each do |key, value_hash|
        @collection << Hash[key, value_hash[:value]]
      end
    end

    def serialize(level = 0)
      buffer = ""
      @collection.each do |hash|
        level.times { buffer << ONE_INDENTATION_LEVEL }
        buffer << "#{hash.keys[0]}: #{hash.values[0]}\n"
      end

      buffer << "\n" unless @collection.blank?
      buffer
    end    
  end

  #
  # Collection of metadata
  #
  class Metadata < KeyValueCollection
  end

  #
  # Collection of headers 
  #
  class Headers < KeyValueCollection
    def serialize(level = 0)
      return "" if @collection.blank?

      buffer = ""
      level.times { buffer << ONE_INDENTATION_LEVEL }
      buffer << "+ Headers\n\n"
      buffer << super(level + 2)
    end      
  end;

  #
  # One URI parameter
  #
  class Parameter < BlueprintNode
    attr_accessor :name
    attr_accessor :description
    attr_accessor :type
    attr_accessor :use
    attr_accessor :default_value
    attr_accessor :example_value
    attr_accessor :values

    def initialize(name = nil, hash = nil)
      super(hash)
      @name = name.to_s if name
    end

    def load_ast_hash!(hash)
      @description = hash[:description]
      @type = hash[:type] if hash[:type]
      @use = (hash[:required] && hash[:required] == true) ? :required : :optional
      @default_value = hash[:default] if hash[:default]
      @example_value = hash[:example] if hash[:example]
      
      unless hash[:values].blank?
        @values = Array.new
        hash[:values].each { |value| @values << value }
      end
    end

    def serialize
      # Parameter name
      buffer = "#{ONE_INDENTATION_LEVEL}+ #{@name}"

      # Default value
      buffer << " = `#{@default_value}`" if @default_value    
    
      # Attributes
      unless @type.blank? && @example_value.blank? && @use == :required
        attribute_buffer = ""
        
        buffer << " ("
        
        # Type
        attribute_buffer << @type unless @type.blank?

        # Use
        if (@use == :optional)
          attribute_buffer << ", " unless attribute_buffer.empty?
          attribute_buffer << "optional"
        end

        # Example value
        unless (@example_value.blank?)
          attribute_buffer << ", " unless attribute_buffer.empty?
          attribute_buffer << "`#{@example_value}`"
        end

        buffer << attribute_buffer
        buffer << ")"
      end

      # Description
      if @description.blank?
        buffer << "\n"        
      else
        if @description.lines.count == 1
          # One line description
          buffer << " ... #{@description}"
        else 
          # Multi-line description
          buffer << "\n\n"
          @description.each_line do |line|
            2.times { buffer << ONE_INDENTATION_LEVEL }
            buffer << "#{line}"
          end
        end
      end

      # Value
      unless @values.blank?
        buffer << "\n"
        2.times { buffer << ONE_INDENTATION_LEVEL }
        buffer << "+ Values\n"
        @values.each do |value|
          3.times { buffer << ONE_INDENTATION_LEVEL }
          buffer << "+ `#{value}`\n" 
        end
      end

      buffer
    end
  end

  #
  # Collection of URI parameters
  #
  class Parameters < BlueprintNode
    attr_accessor :collection

    def load_ast_hash!(hash)
      return if hash.empty?

      @collection = Array.new
      hash.each do |key, value_hash|
        @collection << Parameter.new(key, value_hash)
      end      
    end

    def serialize
      return "" if :collection.blank?
      
      buffer = "+ Parameters\n"
      @collection.each do |parameter|
        buffer << parameter.serialize
      end

      buffer << "\n" unless @collection.blank?
      buffer
    end
  end

  #
  # Generic payload base class
  #
  class Payload < NamedBlueprintNode
    attr_accessor :name
    attr_accessor :description
    attr_accessor :parameters
    attr_accessor :headers
    attr_accessor :body
    attr_accessor :schema

    def load_ast_hash!(hash)
      super(hash)

      @headers = Headers.new(hash[:headers]) unless hash[:headers].blank?
      @body = hash[:body] unless hash[:body].blank?
      @schema = hash[:schema] unless hash[:schema].blank?
    end

    def serialize
      # Name is serialized in Payload successors
      buffer = ""

      unless @description.blank?
        buffer << "\n"
        @description.each_line { |line| buffer << "#{ONE_INDENTATION_LEVEL}#{line}" }
        buffer << "\n"
      end

      unless @headers.blank?
        buffer << @headers.serialize(1)
      end

      unless @body.blank?
        buffer << "#{ONE_INDENTATION_LEVEL}+ Body\n\n"
        @body.each_line do |line| 
          3.times { buffer << ONE_INDENTATION_LEVEL }
          buffer << "#{line}"
        end
        buffer << "\n"
      end

      unless @schema.blank?
        buffer << "#{ONE_INDENTATION_LEVEL}+ Schema\n\n"
        @schema.each_line do |line| 
          3.times { buffer << ONE_INDENTATION_LEVEL }
          buffer << "#{line}"
        end        
        buffer << "\n"
      end

      buffer
    end

    def serialize_lead_in(section_name)
      buffer = ""
      buffer << "+ #{section_name}"
      buffer << " #{@name}" unless @name.blank?
      buffer << "\n"
    end
  end

  #
  # Model Payload
  #
  class Model < Payload
    def serialize
      buffer = "+ Model\n"
      buffer << super
    end
  end

  #
  # Request Payload
  #
  class Request < Payload
    def serialize
      buffer = serialize_lead_in("Request")
      buffer << super
    end    
  end

  #
  # Response Payload
  #
  class Response < Payload;
    def serialize
      buffer = serialize_lead_in("Response")
      buffer << super
    end    
  end

  #
  # Transaction Example
  #
  class TransactionExample < NamedBlueprintNode
    attr_accessor :name
    attr_accessor :description
    attr_accessor :requests
    attr_accessor :responses

    def load_ast_hash!(hash)
      super(hash)

      unless hash[:requests].blank?
        @requests = Array.new
        hash[:requests].each { |request_hash| @requests << Request.new(request_hash) }
      end

      unless hash[:responses].blank?
        @responses = Array.new
        hash[:responses].each { |response_hash| @responses << Response.new(response_hash) }
      end
    end

    def serialize
      buffer = ""
      @requests.each { |request| buffer << request.serialize } unless @requests.nil?
      @responses.each { |response| buffer << response.serialize } unless @responses.nil?
      buffer
    end
  end

  #
  # Action
  #
  class Action < NamedBlueprintNode
    attr_accessor :method
    attr_accessor :name
    attr_accessor :description
    attr_accessor :parameters
    attr_accessor :headers
    attr_accessor :examples

    def load_ast_hash!(hash)
      super(hash)

      @method = hash[:method]
      @parameters = Parameters.new(hash[:parameters]) unless hash[:parameters].blank?
      @headers = Headers.new(hash[:headers]) unless hash[:headers].blank?
      
      unless hash[:examples].blank?
        @examples = Array.new
        hash[:examples].each { |example_hash| @examples << TransactionExample.new(example_hash) }
      end
    end

    def serialize
      buffer = ""
      if @name.blank?
        buffer << "### #{@method}\n"
      else
        buffer << "### #{@name} [#{@method}]\n"
      end

      buffer << "#{@description}" unless @description.blank?

      buffer << @parameters.serialize unless @parameters.nil?
      buffer << @headers.serialize unless @headers.nil?

      @examples.each { |example| buffer << example.serialize } unless @examples.nil?
      buffer
    end    
  end
  
  #
  # Resource
  #
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
      @model = Model.new(hash[:model]) unless hash[:model].blank?
      @parameters = Parameters.new(hash[:parameters]) unless hash[:parameters].blank?
      @headers = Headers.new(hash[:headers]) unless hash[:headers].blank?
      
      unless hash[:actions].blank?
        @actions = Array.new
        hash[:actions].each { |action_hash| @actions << Action.new(action_hash) }
      end
    end

    def serialize
      buffer = ""
      if @name.blank?
        buffer << "## #{@uri_template}\n"
      else
        buffer << "## #{@name} [#{@uri_template}]\n"
      end

      buffer << "#{@description}" unless @description.blank?

      buffer << @model.serialize unless @model.nil?
      buffer << @parameters.serialize unless @parameters.nil?
      buffer << @headers.serialize unless @headers.nil?

      @actions.each { |action| buffer << action.serialize } unless @actions.nil?
      buffer
    end
  end

  #
  # Resource Group
  #
  class ResourceGroup < NamedBlueprintNode
    attr_accessor :name
    attr_accessor :description
    attr_accessor :resources

    def load_ast_hash!(hash)
      super(hash)

      unless hash[:resources].blank?
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

  #
  # Blueprint
  #
  class Blueprint < NamedBlueprintNode
    attr_accessor :metadata
    attr_accessor :name
    attr_accessor :description
    attr_accessor :resource_groups

    def load_ast_hash!(hash)
      super(hash)
      
      # Load Metadata
      unless hash[:metadata].blank?
        @metadata = Metadata.new(hash[:metadata])
      end
      
      # Load Resource Groups
      unless hash[:resourceGroups].blank?
        @resource_groups = Array.new
        hash[:resourceGroups].each { |group_hash| @resource_groups << ResourceGroup.new(group_hash) }
      end
    end

    def serialize
      buffer = ""
      buffer << "#{@metadata.serialize}" unless @metadata.nil?      
      buffer << "# #{@name}\n" unless @name.blank?
      buffer << "#{@description}" unless @description.blank?

      @resource_groups.each { |group| buffer << group.serialize } unless @resource_groups.nil?
      buffer
    end
  end
end
