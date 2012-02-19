# author: Dan Brickley
# patterned after a Python client by Ivan Herman
# modifications: Mark Watson
# license: W3C SOFTWARE NOTICE AND LICENSE (http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231)

require 'open-uri'
require 'rexml/document'
require 'cgi'

module SPARQL 

  # Wrapper around an online access to a SPARQL entry point on the Web.
  class SPARQLWrapper 

    attr_accessor :baseURI, :_querytext, :query_string, :URI, :retval

    def initialize(baseURI) 
      self.baseURI     = baseURI
      self._querytext  = []
      self.query_string = """SELECT * WHERE{ ?s ?p ?o }"""	
      self.retval = nil
      self.URI    = ""
    end			
    # Return the URI as sent (or to be sent) to the SPARQL endpoint. The URI is constructed 
    # with the base URI given at initialization, plus all the other parameters set.
    def fetch_uri		
      self._querytext.push(["query",self.query_string])
      begin
        esc = ""
        self._querytext.each {|a| esc += a[0] + "=" + CGI.escape(a[1]) +"&"}
        self.URI= self.baseURI + "?" + esc           
      rescue
        puts "Something bad with url escaping... #{$!} self.URI: #{self.URI}\n"
      end
      return self.URI
    end
    # Execute the query.
    def query
      QueryResult.new(open(self.fetch_uri).read) rescue puts "Bad things returning query. #{$!} "
    end
  end

  class QueryResult 
    attr_accessor :response
    # @param response: HTTP response stemming from a L{SPARQLWrapper.query} call
    def initialize(response) 
      self.response = response
    end
    # Return the URI leading to this result
    def geturl
      return self.response.geturl
    end		
    # Return the meta-information of the HTTP result
    def info
      return self.response.info
    end
    # Convert an XML result into a dom tree.
    def convertXML    
      return REXML::Document.new(self.response)
    end
  end
end
