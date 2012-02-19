require 'rubygems'
require 'cgi'
require 'json'
require 'pp'

require 'restclient'


protocol = RestClient.get("http://localhost:8080/openrdf-sesame/protocol")
puts protocol

repositories = RestClient.get("http://localhost:8080/openrdf-sesame/repositories", :accept => 'application/sparql-results+json')
#pp repositories
repo_json = JSON.parse(repositories)
pp repo_json

query ="SELECT ?subject ?predicate WHERE {
   ?subject ?predicate <http://knowledgebooks.com/test#Business> .
}"

uri = "http://localhost:8080/openrdf-sesame/repositories/101?query=" + CGI.escape(query)
puts uri
payload = RestClient.get(uri, :accept => 'application/sparql-results+json')
puts payload
json_data = JSON.parse(payload)
pp json_data

## try posting new data:

s = "<http://knowledgebooks.com/test#WorkType>     <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#Class> ."
uri2 = "http://localhost:8080/openrdf-sesame/repositories/101/statements"
status = RestClient.post(uri2, s, :content_type => 'application/x-turtle')
puts status

