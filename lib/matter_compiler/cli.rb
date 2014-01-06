require 'optparse'
require 'matter_compiler/composer'

module MatterCompiler
  
  class CLI
    
    attr_reader :command

    def self.start
      cli = CLI.new
      options = cli.parse_options!(ARGV)
      cli.runCommand(ARGV, options)
    end

    def runCommand(args, options)
      command = :compose if args.first.nil? || @command.nil?
      command = @command if @command

      if command == :compose && args.first.nil? && (options[:format].nil? || options[:format] == :unknown_ast)

        print options[:format] ? "invalid value of" : "missing"
        print " '--format option'\n\n"

        CLI::help
        exit 1
        end

      case command
      when :compose
        Composer.compose(args.first, options[:format])
      when :version
        puts MatterCompiler::VERSION
      else
        CLI::help
      end
          
    end

    def parse_options!(args)
      @command = nil
      options = {}
      options_parser = OptionParser.new do |opts|
        opts.on('-f', '--format (yaml|json)') do |format|
          options[:format] = Composer.parse_format(format)
          @command = :compose
        end

        opts.on('-v', '--version') do
          @command = :version
        end

        opts.on( '-h', '--help') do
          @command = :help
        end
      end

      options_parser.parse!
      options

    rescue OptionParser::InvalidOption => e
      puts e
      CLI::help
      exit 1
    end

    def self.help
        puts "Usage: matter_compiler [options] [<ast file>]"
        puts "\nCompose an API blueprint from its AST."
        puts "If no <ast file> is specified 'matter_compiler' will listen on stdin."
        
        puts "\nOptions:\n\n"
        puts "\t-f, --format (yaml|json)        Set the AST media-type format of the input"
        puts "\t-h, --help                      Show this help"
        puts "\t-v, --version                   Show version"
        puts "\n"
    end

  end

end
