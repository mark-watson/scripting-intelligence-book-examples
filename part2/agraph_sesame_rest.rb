require 'rubygems'
require 'cgi'
require 'json'
require 'pp'

require 'restclient'

#protocol = RestClient.get("http://localhost:8111/sesame/repositories/protocol")  # agraph
protocol = RestClient.get("http://localhost:8080/openrdf-sesame/repositories")   # Tomcat + Sesame

puts protocol

query ="SELECT ?s WHERE {
  ?s
  <http://www.w3.org/1999/02/22-rdf-syntax-ns#type>
  <http://www.w3.org/2000/01/rdf-schema#Class>
}"

#uri = "http://localhost:8111/sesame/repositories/test?query=" + CGI.escape(query)   # agraph
uri = "http://localhost:8080/openrdf-sesame/repositories/test?query=" + CGI.escape(query)   # Tomcat + Sesame
puts uri
payload = RestClient.get(uri, :accept => 'application/sparql-results+json')
puts payload
json_data = JSON.parse(payload)
pp json_data

