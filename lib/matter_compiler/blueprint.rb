# The classes in this module should be 1:1 with the Snow Crash AST
# counterparts (https://github.com/apiaryio/snowcrash/blob/master/src/Blueprint.h).
module MatterCompiler
  
  # Blueprint AST node
  #   Base class for API Blueprint AST nodes in Matter Compiler.
  #
  # @abstract
  class BlueprintNode
    
    ONE_INDENTATION_LEVEL = "    "

    # Initialize the node
    #
    # @param hash [Hash, nil] a hash to initialize the node with or nil
    def initialize(hash = nil)
      load_ast_hash!(hash) if hash
    end

    # Load AST hash content into node
    #
    # @param hash [Hash] a hash to load
    def load_ast_hash!(hash)
    end

    # Serialize node to a Markdown string buffer
    #
    # @param level [Integer, 0] requested indentation level
    # @return [String, nil] content of the node serialized into Markdown or nil
    def serialize(level = 0)
    end
  end

  # Blueprint AST node with name and description associated
  # 
  # @attr name [String] name of the node
  # @attr description [String] description of the node
  #
  # @abstract
  class NamedBlueprintNode < BlueprintNode

    attr_accessor :name
    attr_accessor :description

    def load_ast_hash!(hash)
      @name = hash[:name]
      @description = hash[:description]
    end

    # Ensure the input string buffer ends with two newlines.
    #
    # @param buffer [String] a buffer to check 
    #   If the buffer does not ends with two newlines the newlines are added.
    def ensure_description_newlines(buffer)
      return if description.blank?

      if description[-1, 1] != "\n"
        buffer << "\n\n"
      elsif description.length > 1 && description[-2, 1] != "\n"
        buffer << "\n"
      end    
    end        
  end

  # Blueprint AST node for key-value collections
  # 
  # @abstract
  # @attr collection [Array<Hash>] array of key value hashes
  class KeyValueCollection < BlueprintNode
    
    attr_accessor :collection

    def load_ast_hash!(hash)
      return if hash.empty?
      @collection = Array.new
      hash.each do |key, value_hash|
        @collection << Hash[key, value_hash[:value]]
      end
    end

    # Serialize key value collection node to a Markdown string buffer
    #
    # @param ignore_keys [Array<String>] array of keys that should be ignored (skipped) during the serialization
    def serialize(level = 0, ignore_keys = nil)
      buffer = ""
      @collection.each do |hash|
        unless ignore_keys && ignore_keys.include?(hash.keys.first)
          level.times { buffer << ONE_INDENTATION_LEVEL }
          buffer << "#{hash.keys.first}: #{hash.values.first}\n"
        end
      end

      buffer << "\n" unless buffer.empty?
      buffer
    end

    # Filter collection keys
    # 
    # @returns [Array<Hash>] collection without ignored keys
    def ignore(ignore_keys)
      return @collection if ignore_keys.blank?
      @collection.select { |kv_item| !ignore_keys.include?(kv_item.keys.first) }
    end    
  end

  # Metadata collection Blueprint AST node
  #   represents 'metadata section'
  class Metadata < KeyValueCollection
  end

  # Headers collection Blueprint AST node
  #   represents 'headers section'
  class Headers < KeyValueCollection

    # HTTP 'Content-Type' header
    CONTENT_TYPE_HEADER_KEY = :'Content-Type'

    def serialize(level = 0, ignore_keys = nil)
      return "" if @collection.blank? || ignore(ignore_keys).blank?

      buffer = ""
      level.times { buffer << ONE_INDENTATION_LEVEL }
      buffer << "+ Headers\n\n"
      buffer << super(level + 2, ignore_keys)
    end

    # @return [String] the value of 'Content-type' header if present or nil
    def content_type
      content_type_header = @collection.detect { |header| header.has_key?(CONTENT_TYPE_HEADER_KEY) }
      return (content_type_header.nil?) ? nil : content_type_header[CONTENT_TYPE_HEADER_KEY]
    end
  end;

  # URI parameter Blueprint AST node
  #   represents one 'parameters section' parameter
  #
  # @attr type [String] an arbitrary type of the parameter or nil
  # @attr use [Symbol] parameter necessity flag, `:required` or `:optional`
  # @attr default_value [String] default value of the parameter or nil
  #   This is a value used when the parameter is ommited in the request.
  # @attr example_value [String] example value of the parameter or nil
  # @attr values [Array<String>] an enumeration of possible parameter values
  class Parameter < NamedBlueprintNode

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
      super(hash)

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
          buffer << "\n" if @description[-1, 1] != "\n" # Additional newline needed if no provided
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

  # Collection of URI parameters Blueprint AST node
  #   represents 'parameters section'
  #
  # @attr collection [Array<Parameter>] an array of URI parameters
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

  # HTTP message payload Blueprint AST node
  #   base class for 'payload sections'
  #
  # @abstract
  # @attr parameters [Array] ignored
  # @attr headers [Array<Headers>] array of HTTP header fields of the message or nil
  # @attr body [String] HTTP-message body or nil
  # @attr schema [String] HTTP-message body validation schema or nil
  class Payload < NamedBlueprintNode
  
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
        buffer << @headers.serialize(1, [Headers::CONTENT_TYPE_HEADER_KEY])
      end

      unless @body.blank?
        abbreviated_synax = (headers.blank? || headers.ignore([Headers::CONTENT_TYPE_HEADER_KEY]).blank?) \
                              & description.blank? \
                              & schema.blank?
        asset_indent_level = 2
        unless abbreviated_synax
          asset_indent_level = 3
          buffer << "#{ONE_INDENTATION_LEVEL}+ Body\n"
        end
        buffer << "\n"

        got_new_line = false
        @body.each_line do |line| 
          asset_indent_level.times { buffer << ONE_INDENTATION_LEVEL }
          buffer << "#{line}"
          got_new_line = line[-1, 1] == "\n"
        end
      
        buffer << "\n" unless got_new_line
        buffer << "\n"
      end

      unless @schema.blank?
        buffer << "#{ONE_INDENTATION_LEVEL}+ Schema\n\n"

        got_new_line = false
        @schema.each_line do |line| 
          3.times { buffer << ONE_INDENTATION_LEVEL }
          buffer << "#{line}"
          got_new_line = line[-1, 1] == "\n"
        end 

        buffer << "\n" unless got_new_line
        buffer << "\n"
      end

      buffer << "\n" if buffer.empty? # Separate empty payloads by a newline

      buffer
    end

    # Serialize payaload's definition (lead-in)
    #
    # @param section [String] section type keyword
    # @param ignore_name [Boolean] object to ignore section name in serialization, false otherwise
    # @return [String] buffer with serialized section definition
    def serialize_definition(section, ignore_name = false)
      buffer = ""
      buffer << "+ #{section}"
      buffer << " #{@name}" unless ignore_name || @name.blank? 

      unless @headers.blank? || @headers.content_type.blank?
        buffer << " (#{@headers.content_type})"
      end

      buffer << "\n"
    end
  end

  # Model Payload Blueprint AST node
  #   represents 'model section'
  class Model < Payload
    def serialize
      buffer = serialize_definition("Model", true)
      buffer << super
    end
  end

  # Request Payload Blueprint AST node
  #   represents 'request section'
  class Request < Payload
    def serialize
      buffer = serialize_definition("Request")
      buffer << super
    end    
  end

  # Response Payload
  #   represents 'response section'
  class Response < Payload;
    def serialize
      buffer = serialize_definition("Response")
      buffer << super
    end    
  end

  # Transaction example Blueprint AST node
  #
  # @attr requests [Array<Request>] example request payloads
  # @attr response [Array<Response>] example response payloads
  class TransactionExample < NamedBlueprintNode

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

  # Action Blueprint AST node
  #   represetns 'action sction'
  #
  # @attr method [String] HTTP request method or nil
  # @attr parameters [Parameters] action-specific URI parameters or nil
  # @attr examples [Array<TransactionExample>] action transaction examples 
  class Action < NamedBlueprintNode

    attr_accessor :method
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
      ensure_description_newlines(buffer)

      buffer << @parameters.serialize unless @parameters.nil?
      buffer << @headers.serialize unless @headers.nil?

      @examples.each { |example| buffer << example.serialize } unless @examples.nil?
      buffer
    end    
  end
  
  # Resource Blueprint AST node
  #   represents 'resource section' 
  #
  # @attr uri_template [String] RFC 6570 URI template
  # @attr model [Model] model payload for the resource or nil
  # @attr parameters [Parameters] action-specific URI parameters or nil
  # @attr actions [Array<Action>] array of resource actions or nil
  class Resource < NamedBlueprintNode

    attr_accessor :uri_template
    attr_accessor :model
    attr_accessor :parameters
    attr_accessor :headers
    attr_accessor :actions

    def load_ast_hash!(hash)
      super(hash)

      if hash[:uriTemplate].blank? || hash[:uriTemplate][0] != '/'
        failure_message = "Invalid input: A resource is missing URI template"
        failure_message << " ('#{hash[:name]}' resource)" unless hash[:name].blank?
        abort(failure_message);
      end

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
      ensure_description_newlines(buffer)

      buffer << @model.serialize unless @model.nil?
      buffer << @parameters.serialize unless @parameters.nil?
      buffer << @headers.serialize unless @headers.nil?

      @actions.each { |action| buffer << action.serialize } unless @actions.nil?
      buffer
    end
  end

  # Resource group Blueprint AST node
  #   represents 'resource group section'
  #
  # @attr resources [Array<Resource>] array of resources in the group
  class ResourceGroup < NamedBlueprintNode

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
      ensure_description_newlines(buffer)

      @resources.each { |resource| buffer << resource.serialize } unless @resources.nil?
      buffer
    end
  end


  # Top-level Blueprint AST node
  #   represents 'blueprint section'
  #
  # @attr metadata [Metadata] tool-specific metadata collection or nil
  # @attr resource_groups [Array<ResourceGroup>] array of blueprint resource groups
  class Blueprint < NamedBlueprintNode

    attr_accessor :metadata
    attr_accessor :resource_groups

    VERSION_KEY = :_version
    SUPPORTED_VERSIONS = ["1.0"]

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

    def serialize(set_blueprint_format = false)
      buffer = ""
      
      if set_blueprint_format
        buffer << "FORMAT: 1A\n"
        if @metadata
          buffer << "#{@metadata.serialize(0, [:FORMAT])}"
        else
          buffer << "\n"
        end
      else
        buffer << "#{@metadata.serialize}" unless @metadata.nil?
      end

      buffer << "# #{@name}\n" unless @name.blank?
      buffer << "#{@description}" unless @description.blank?
      ensure_description_newlines(buffer)

      @resource_groups.each { |group| buffer << group.serialize } unless @resource_groups.nil?
      buffer
    end

  end
end
