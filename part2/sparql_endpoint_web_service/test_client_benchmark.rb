require 'rubygems'
require 'open-uri'
require 'cgi'
require 'json'
require 'pp'

server_uri = "http://localhost:4567/?query="
example_query = "SELECT ?s ?o WHERE { ?s <http:://knowledgebooks.com/ontology/#summary> ?o }"

200.times {|i|
  data = open(server_uri + CGI.escape(example_query)).read
  data = JSON.parse(data)
  puts "test cycle #{i}"
  sleep(0.05)
}