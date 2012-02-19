require 'rubygems'
require 'cgi'
require 'rexml/document'
include REXML

require 'restclient'

ROOT_SEARCH_URL = 'http://localhost:8080/opensearch?query='
query = 'text clustering categorization tools'

url = ROOT_SEARCH_URL + CGI.escape(query)
results = RestClient.get(url)
xml_doc = Document.new(results)
xml_doc.write($stdout, 0)
