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

class OpenCalaisEntities
  attr_reader :person_data, :place_data, :company_data
  def initialize text=""
    data = "licenseID=#{MY_KEY}&content=" + CGI.escape(text)
    http = SimpleHttp.new "http://api.opencalais.com/enlighten/calais.asmx/Enlighten"
    @response = CGI.unescapeHTML(http.post(data+PARAMS))
    @person_data = []
    @place_data = []
    @company_data = []
    Document.new(@response).elements.each("//rdf:Description") {|description| # puts "\n\n"; pp description; pp description.attributes;
      about = name = type = nil
      uri = description.attributes['about']
      description.elements.each("rdf:type") {|e|
        # collect person data:
        type = 'Person' if e.to_s == "<rdf:type rdf:resource='http://s.opencalais.com/1/type/em/e/Person'/>"
        # collect place data:
        if e.to_s == "<rdf:type rdf:resource='http://s.opencalais.com/1/type/er/Geo/City'/>" ||
           e.to_s == "<rdf:type rdf:resource='http://s.opencalais.com/1/type/er/Geo/Country'/>" ||
           e.to_s == "<rdf:type rdf:resource='http://s.opencalais.com/1/type/em/e/City'/>" ||
           e.to_s == "<rdf:type rdf:resource='http://s.opencalais.com/1/type/em/e/Country'/>"
          type = 'Place'
        end
        # collect company data:
        if e.to_s == "<rdf:type rdf:resource='http://s.opencalais.com/1/type/er/Company'/>" ||
           e.to_s == "<rdf:type rdf:resource='http://s.opencalais.com/1/type/em/e/Company'/>"
          type = 'Company'
        end
      }
      description.elements.each("c:name") {|e| name = e.text if type}
      if uri && name
        @person_data << [uri, name] if type == 'Person'
        @place_data << [uri, name]  if type == 'Place'
        @company_data << [uri, name]  if type == 'Company'
      end
    }
  end
end

tt = OpenCalaisEntities.new("President George Bush and President Barack Obama played basketball in London and in Paris France at IBM")

pp "people:", tt.person_data
pp "places:", tt.place_data
pp "companies:", tt.company_data
