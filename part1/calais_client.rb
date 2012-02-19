require 'rubygems'
require 'simple_http'
require "rexml/document"
include REXML

module CalaisClient
  VERSION = '0.0.1'
  MY_KEY = ENV["OPEN_CALAIS_KEY"]
  raise(StandardError,"Set Open Calais login key in ENV: 'OPEN_CALAIS_KEY'") if !MY_KEY

  PARAMS = "&paramsXML=" + CGI.escape('<c:params xmlns:c="http://s.opencalais.com/1/pred/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"><c:processingDirectives c:contentType="text/txt" c:outputFormat="xml/rdf"></c:processingDirectives><c:userDirectives c:allowDistribution="true" c:allowSearch="true" c:externalID="17cabs901" c:submitter="ABC"></c:userDirectives><c:externalMetadata></c:externalMetadata></c:params>')

  class OpenCalaisTaggedText
    def initialize text=""
      data = "licenseID=#{MY_KEY}&content=" + CGI.escape(text)
      http = SimpleHttp.new "http://api.opencalais.com/enlighten/calais.asmx/Enlighten"
      @response = CGI.unescapeHTML(http.post(data+PARAMS))
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
      # now, just keep the tags we want:
      ret = {}
      ["City", "Organization", "Country", "Company"].each {|ttype|
        ret[ttype] = h[ttype]
      }
      vals = []
      h["Person"].each {|p|
        vals << p if p.split.length > 1        
      }
      ret["Person"] = vals
      ret["State"] = h["ProvinceOrState"]
      ret
    end 
    def get_semantic_XML
      @response
    end
    def pp_semantic_XML
      Document.new(@response).write($stdout, 0)
    end
  end
  
end