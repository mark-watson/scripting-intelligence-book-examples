require 'rubygems'
require 'open-uri'
require 'nokogiri'

require 'pp'

#doc = Nokogiri::HTML(open('http://markwatson.com/'))
#doc = Nokogiri::XML(open("test.xml"))
#pp (doc.public_methods - Object.public_methods).sort

#pp doc.content
#pp doc.text.class

def text_from_xml filename
  doc = Nokogiri::XML(open("test.xml"))
  pp doc.class
  doc.text.gsub("\n", ' ').gsub("\t", ' ').split.join(' ')
end

pp text_from_xml("test.xml")