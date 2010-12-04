require 'fileutils'

module Conversio

class Hash

 def deep_merge(hash)
    target = dup
    
    hash.keys.each do |key|
      if hash[key].is_a? Hash and self[key].is_a? Hash
        target[key] = target[key].deep_merge(hash[key])
        next
      end
      
      target[key] = hash[key]
    end
    
    target
  end


  def deep_merge!(second)
    second.each_pair do |k,v|
      if self[k].is_a?(Hash) and second[k].is_a?(Hash)
        self[k].deep_merge!(second[k])
      else
        self[k] = second[k]
      end
    end
  end
end


class Converter

  attr_accessor :table_of_content, :color

  def initialize(template)
    @template = template
    @table_of_content = false
    @color = false
    #user_config = "#{ENV['HOME']}/.conversiorc"
    #if File.exists?(user_config)
      # overwrite defaults
      #@meta_data = @meta_data.deep_merge(YAML.load_file(user_config))
    #end
    # Holds the input Markdown plain text
    @source = nil
    # Hold Markdown rendered to HTML
    @content = nil
    # Hold the finished XHTML document
    @result = nil
    # load the default parser
    @parser = 'bluecloth'
    load_parser(@parser)
  end

  def markdown_to_xhtml(src,dst)
    @source = open(src).readlines.join
    colorize() if @color 
    parse()    
    generate_table_of_content() if @table_of_content
    render()
    # write the HTML file
    FileUtils::mkdir_p(File.dirname(dst)) unless File.exists?(File.dirname(dst))
    open(dst,'w') { |f| f.write @result }
  end

  def load_parser(parser)
    begin
      case parser
      when 'bluecloth'
        require 'bluecloth'
      when 'kramdown'
        require 'kramdown'
      else
        raise "Parser '#{parser}' is not a known Markdown library"
      end
    rescue LoadError
      raise "Couldn't load #{parser}."
    end
    @parser = parser
  end

  private

  def configure()
    config = nil
    # read the header of the source file
    start = @source.index("|--")
    ende = @source.index("--|")
    #if start != nil and ende != nil then
    if false
      STDERR.puts 'Meta data found in file!' if $DEBUG
      yamlheader = @source[start+3,ende-start-3]
      # overwrite defaults
      config = @meta_data.deep_merge(YAML.load(yamlheader))
      splitted =  @source.split('--|',2)
      @source = splitted[1]
    else
      config = @meta_data
    end
    return config
  end

  def load_template(tpl)
    puts "Loading template : "+tpl.to_s
    raise "Couldn't open ERB template: #{tpl}" unless File.exists?(File.expand_path(tpl))
    return open(File.expand_path(tpl)).readlines.join
  end

  def parse
    raise "Define source before rendering!" if @source == nil
    case @parser
    when 'bluecloth'
      @content = BlueCloth::new(@source).to_html
    when 'kramdown'
      @content = Kramdown::Document.new(@source).to_html
    else 
      puts "Markdown parser #{@parser} not supported yet"
    end
  end

  def colorize 
     @source = Pygmentizer.new.transform_code_blocks(@source)
  end

  def generate_table_of_content #füge zum geparsten Text ein Inhaltsverzeichnis hinzu -> davor parsen
    raise "No content to generate table of content - Run the parser first!" if @content == nil
    @content = HTMLTableOfContent.new(@content, @table_of_content).get_html()
  end

  def render(values = {})
    values.store(:content, @content)
    @result = ERB.new(@template).result(binding)
  end

end

end
