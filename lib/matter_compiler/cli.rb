require 'thor'

module MatterCompiler
  class CLI < Thor

  desc 'compose <file>', 'Compose API blueprint from its AST <file>'
  def compose(file=nil)
  	# TODO:
    puts 'perplex API composed'
  end

  default_task :compose
  end  
end