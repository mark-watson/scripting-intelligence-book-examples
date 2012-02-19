require 'pp'

require "rexml/document"
doc = REXML::Document.new(File.new("test.xml"))
#pp (doc.public_methods - Object.public_methods).sort

#doc.each_recursive {|elem| pp elem.attributes.values; pp elem.text; puts ''}

def text_from_xml filename
  str = ''
  doc = REXML::Document.new(File.new(filename))
  doc.each_recursive {|elem|
    str << elem.text.strip + ' '
    str << elem.attributes.values.join(' ').strip + ' '
    pp (elem.attributes.public_methods - Object.public_methods).sort
  }
  str
end

puts text_from_xml('test.xml')