#!/usr/bin/env ruby
require 'rexml'

class NoTerm
  def initialize
  end

  def emit_delta
    ""
  end
  
  def reset_color
  end
  
  def color= c
  end

  def bg= c
  end
  
  def bold= yes
  end

  def underline= yes
  end

  def italic= yes
  end
end

class VT100
  attr_reader :current_state, :last_state
  
  def initialize
    @current_state = {
      color: 0x39,
      bg: 0x49,
      bold: 0,
      italic: 0x23,
      underline: 0x24
    }
    @last_state = @current_state.clone
  end

  def reset_color
    current_state[:color] = 0x39
    current_state[:bg] = 0x49
  end

  Colors = %w(black red green yellow blue magenta cyan white)
  ColorsByName = Colors.each_with_index.reduce({}) { |h, (c, n)| h[c] = n; h }
  
  def color_by_name c
    case c
    when Integer then c
    else ColorsByName[c.gsub('bright', '')] || 7
    end
  end
  
  def color= c
    n = color_by_name(c)
    if false && c =~ /bright/
      n += 0x90
    else
      n += 0x30
    end
    current_state[:color] = n
  end

  def bg= c
    n = color_by_name(c)
    if false && c =~ /bright/
      n += 0x10
    else
      n += 0x40
    end
    current_state[:bg] = n
  end

  def emit_delta
    delta = current_state.to_a - last_state.to_a
    if delta.empty?
      ""
    else
      attrs = delta.collect do |attr, value|
        value.to_s(16)
      end
      delta.each { |(a, v)| last_state[a] = v }
      "\e[%sm" % [ attrs.join(';') ]
    end
  end
  
  def bold= yes
    current_state[:bold] = yes ? 1 : 0
  end

  def underline= yes
    current_state[:underline] = yes ? 4 : 0x24
    reset_color if yes
  end

  def italic= yes
    current_state[:italic] = yes ? 3 : 0x23
  end
end

def unescape xml
  if xml
    xml.gsub('&lt;', '<').gsub('&gt;', '>').gsub('&amp;', '&')
  else
    ''
  end
end

def enrich doc, out = $stdout, vt100 = nil
  vt100 ||= VT100.new
  #vt100 ||= NoTerm.new(out)
  doc.each_child do |e, r|
    case e
    when REXML::Text then out.write(vt100.emit_delta + unescape(e.to_s))
    else
      case e.name
      when 'x-color' then
        enrich(e, out, vt100)
        vt100.reset_color
      when 'param' then
        case doc.name
        when 'x-color' then
          vt100.color = e.text
        end
      when 'bold' then
        vt100.bold = true
        enrich(e, out, vt100)
        vt100.bold = false
      when 'italic' then
        vt100.italic = true
        enrich(e, out, vt100)
        vt100.italic = false
      when 'underline' then
        vt100.underline = true
        enrich(e, out, vt100)
        vt100.underline = false
      when 'bigger' then
        vt100.underline = true
        vt100.bold = true
        # out.write(vt100.emit_delta)
        # out.puts(" " * e.text.size)
        # vt100.underline = false
        # vt100.bold = false
        # out.puts(vt100.emit_delta)        
        # vt100.underline = false
        # vt100.bold = true
        out.write(vt100.emit_delta + unescape(e.text))
        vt100.underline = false
        vt100.bold = false
      when 'root' then enrich(e, out, vt100)
      else enrich(e, out, vt100) #out.write(vt100.emit_delta + unescape(e.text))
      end
    end
  end
end


if __FILE__ == $0
  mime = ARGF.readline
  width = ARGF.readline
  _ = ARGF.readline
  data = ARGF.read
  x = REXML::Document.new('<root>' + data.gsub('&', '&amp;').gsub('<<', '&lt;') + '</root>')
  term = ENV['STRIPED'] ? NoTerm.new : nil
  enrich(x, $stdout, term)
end
