# Copyright Mark Watson 2008. All rights reserved.
# Can be used under either the Apache 2 or the LGPL licenses.

require 'rubygems' # needed for Ruby 1.8.6
require 'simplehttp'

require "rexml/document"
include REXML

require 'pp'

MY_KEY = ENV["OPEN_CALAIS_KEY"]
raise(StandardError,"Set Open Calais login key in ENV: 'OPEN_CALAIS_KEY'") if !MY_KEY

PARAMS = "&paramsXML=" + CGI.escape('<c:params xmlns:c="http://s.opencalais.com/1/pred/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"><c:processingDirectives c:contentType="text/txt" c:outputFormat="xml/rdf"></c:processingDirectives><c:userDirectives c:allowDistribution="true" c:allowSearch="true" c:externalID="17cabs901" c:submitter="ABC"></c:userDirectives><c:externalMetadata></c:externalMetadata></c:params>')

class OpenCalaisTaggedText
  attr_reader person_data
  def initialize text=""
    data = "licenseID=#{MY_KEY}&content=" + CGI.escape(text)
    http = SimpleHttp.new "http://api.opencalais.com/enlighten/calais.asmx/Enlighten"
    @response = CGI.unescapeHTML(http.post(data+PARAMS))
    @person_data = []
    Document.new(@response).elements.each("//rdf:Description") {|description| # puts "\n\n"; pp description; pp description.attributes;
    about = name = type = nil
    uri = description.attributes['about']
    description.elements.each("rdf:type") {|e|
      type = 'Person' if e.to_s == "<rdf:type rdf:resource='http://s.opencalais.com/1/type/em/e/Person'/>"
    }
    description.elements.each("c:name") {|e| name = e.text if type}
    puts "#{uri} : #{name} : #{type}"
    @person_data << [uri, name, type] if uri && name && type
}

  end
  def get_tags
    h = {}
    index1 = @response.index('terms of service.-->')
    index1 = @response.index('<!--', index1)
    index2 = @response.index('-->', index1)
    txt = @response[index1+4..index2-1]
    lines = txt.split("\n")
    lines.each {|line|
      index = line.index(":")
      h[line[0...index]] = line[index+1..-1].split(',').collect {|x| x.strip} if index
    }
    h
  end 
  def get_semantic_XML
    @response
  end
  def pp_semantic_XML
    Document.new(@response).write($stdout, 0)
  end
  def get_DOM
    Document.new(@response)
  end
end

#tt = OpenCalaisTaggedText.new("President George Bush and Tony Blair spoke to Congress")
tt = OpenCalaisTaggedText.new("President George Bush and President Barack Obama played basketball.")

pp "tags:", tt.get_tags
puts ""
puts ""
#pp "REXML document:", tt.get_semantic_XML
#puts ""
#puts ""
#puts "Semantic XML pretty printed:"
#puts ""
#puts ""
#tt.pp_semantic_XML
#pp tt.get_DOM.methods.sort
#tt.get_DOM.elements.each("//c:name") {|e| puts "\n\n"; pp e; pp e.text}
tt.get_DOM.elements.each("//rdf:Description") {|description| # puts "\n\n"; pp description; pp description.attributes;
  about = name = type = nil
  uri = description.attributes['about']
  description.elements.each("rdf:type") {|e|
    type = 'Person' if e.to_s == "<rdf:type rdf:resource='http://s.opencalais.com/1/type/em/e/Person'/>"
  }
  description.elements.each("c:name") {|e| name = e.text if type}
  puts "#{uri} : #{name} : #{type}"
}

#File.open('/Users/markw/Desktop/calais.rdf', 'w') do |f2| 
#  f2.puts(tt.get_semantic_XML)  
#end  

