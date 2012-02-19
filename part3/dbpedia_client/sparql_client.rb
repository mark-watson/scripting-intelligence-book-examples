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

    attr_accessor :baseURI, :_querytext, :queryString, :URI, :retval

    def initialize(baseURI) 
      self.baseURI     = baseURI
      self._querytext  = []
      self.queryString = """SELECT * WHERE{ ?s ?p ?o }"""	
      self.retval = nil
      self.URI    = ""
    end			
    # Set the SPARQL query text. Note: no check is done on the query (syntax or otherwise)
    def setQuery(query) 
      self.queryString = query
    end
    # Return the URI as sent (or to be sent) to the SPARQL endpoint. The URI is constructed 
    # with the base URI given at initialization, plus all the other parameters set.
    def getURI		
      self._querytext.push(["query",self.queryString])
      begin
        esc = ""
        self._querytext.each {|a| esc += a[0] + "=" + CGI.escape(a[1]) +"&"}
        self.URI= self.baseURI + "?" + esc           
      rescue
        puts "Something bad with url escaping... #{$!} self.URI: #{self.URI}\n"
      end
      return self.URI
    end
    # Internal method to execute the query. Returns the output of the 
    def _query
      puts "** _query: #{self.getURI}"
      data = open(self.getURI).read
      puts "** _query: data: #{data}"
      data
    end	
    # Execute the query.
    def query
      QueryResult.new(self._query) rescue puts "Bad things returning query. #{$!} "
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
