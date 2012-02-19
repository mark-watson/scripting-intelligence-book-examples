require 'rubygems'
require 'open-uri'
require 'cgi'
require 'json'
require 'pp'

server_uri = "http://localhost:4567/?concise&dot&query="
example_query = "SELECT ?s ?o WHERE { ?s <http://knowledgebooks.com/ontology/#summary> ?o }"
puts "Example query:\n#{example_query}\n"

loop do
  puts "\nEnter a SPARQL query:"
  line = gets.strip
  break if line.length == 0
  puts server_uri + CGI.escape(line)
  data = open(server_uri + CGI.escape(line)).read
  data = JSON.parse(data)
  puts "Results:"
  pp data
end