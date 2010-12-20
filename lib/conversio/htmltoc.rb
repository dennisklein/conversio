module Conversio

class HTMLTableOfContent
  
  attr_accessor :numbering, :table_of_content_div_class
  
  def initialize(html_input, style)
    @numbering = true
    @style = style
    @table_of_content_div_class = 'toc'
    # Variables
    @html_input = Array.new
    @heading_elements = Array.new
    html_input.split("\n").each { |l| @html_input << l }
    scan_for_heading_elements()
    numbers()
  end

  def get_html_with_anchors()
    inject_anchors()
    return @html_input.join("\n")
  end

  def get_html_table_of_content()
    output = String.new
    case @style
    when 'div'
      output << get_html_toc_div_style()
    when 'list'
      output << get_html_toc_list_style()
    end
    return %{<div class="#{@table_of_content_div_class}" id="toc">\n#{output}</div>\n}
  end

  # renders <ol>/<li>-elements
  def get_html_toc_list_style()
    output = String.new
    last_level = 0
    indent = "  "
    @heading_elements.each do |heading|
      index, level, content, anchor, number = heading
      level = level.to_i
      next if level > 3 # onyl h1, h2 and h3 elements are used
      #content = numbering? ? "<span class=\"numbering\">#{number}</span>&nbsp;#{content}" : content
      li = "<a href=\"##{anchor}\">#{content}</a>"
      output << "\n<ol>\n<li>#{li}" if last_level < level
      output << "</li>\n<li>#{li}" if last_level == level
      if last_level > level then
        (last_level-1).downto(level) do |level|
          output << "</li>\n</ol>"
        end
        output << "</li>\n<li>#{li}"
      end
      last_level = level
   end
   (last_level-1).downto(0) do |level|
     output << "</li>\n</ol>"
   end
   output << "\n"
   return output
  end

  # renders <div>-elements and hardcoded &nbsp indentation
  def get_html_toc_div_style()
    output = String.new
    @heading_elements.each do |heading|  
      index, level, content, anchor, number = heading
      level = level.to_i
      next if level > 3 # only h1, h2 and h3 elements are used
      space = '&nbsp;&nbsp;'
      case level
      when 2 then output << space
      when 3 then output << space << space
      end
      content = "#{number}&nbsp;#{content}" if numbering?
      output << %{<a href="##{anchor}">#{content}</a><br/>\n}
    end
    return output
  end

  def get_html()
    toc = get_html_table_of_content()
    content = get_html_with_anchors()
    toc_pattern = Regexp.new("%TOC")
    if ( content.sub!(toc_pattern, toc) ) then
      return content
    else
      return toc << "\n" << content
    end
  end

  protected
  
  def numbering?
    return @numbering
  end

  def scan_for_heading_elements()
    toc_found = @html_input.join.scan("%TOC").empty?
    @html_input.each_index do |index|
      if toc_found then
        if @html_input[index] =~ %r{<h(\d)(.*?)>(.*?)</h\1>$}m then
          # Pattern match values:
          #  $1 -- header tag level, e.g. <h2>...</h2> will be 2
          #  $3 -- content between the tags
          @heading_elements << [index, $1, $3, anchor($3)]
        end
      else
        toc_found = !@html_input[index].scan("%TOC").empty?
      end
    end
  end

  # Transforms the input string into a valid XHTML anchor (ID attribute).
  # 
  #   anchor("Text with spaces")                   # textwithspaces
  #   anchor("step 1 step 2 step: 3")              # step1step2step3
  def anchor(string)
    alnum = String.new
    string.gsub(/[[:alnum:]]/) { |c| alnum << c }
    return alnum.downcase
  end

  def numbers()
    chapters = 0
    sections = 0
    subsections = 0
    @heading_elements.each_index do |index|
      level = @heading_elements[index][1].to_i
      case level
      when 1
        chapters = chapters.next
        @heading_elements[index] << "#{chapters}"
        sections = 0
        subsections = 0
      when 2
        sections = sections.next
        @heading_elements[index] << "#{chapters}.#{sections}"
        subsections = 0
      when 3
        subsections = subsections.next
        @heading_elements[index] << "#{chapters}.#{sections}.#{subsections}"
      end
    end
  end

  def inject_anchors()
    @heading_elements.each do |heading|
      line = String.new
      index = heading[0]
      level = heading[1].to_i
      content = heading[2]
      anchor = heading[3]
      next if level > 3 # only h1,h2, and h3 tags are used 
      case @style
      when "div"
        if numbering? then 
          number = heading[4] 
          line = %{<h#{level}><a name="#{anchor}"></a><span class="numbering">#{number}</span>&nbsp;#{content}</h#{level}>}
        else
          line = %{<h#{level}><a name="#{anchor}"></a>#{content}</h#{level}>}
        end
      when "list"
          line = %{<h#{level}><a name="#{anchor}"></a>#{content}</h#{level}>}
      end
      @html_input[index] = line
    end
  end

end

end

