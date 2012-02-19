require "rubygems"
require "sparql_client"
require 'pp'

qs="
SELECT distinct ?name ?person WHERE {
			   ?person foaf:name ?name .
}
LIMIT 5
"
endpoint="http://dbpedia.org/sparql"
sparql = SPARQL::SPARQLWrapper.new(endpoint)
sparql.setQuery(qs)
ret = sparql.query()
#pp ret
puts ret.response
