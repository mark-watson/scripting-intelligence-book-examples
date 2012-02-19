require "rubygems"
require "sparql_client"
require 'memcache'
require 'benchmark'

CACHE = MemCache::new('localhost:11211', :namespace => 'dbpedia')

def sparql_query_cache endpoint, query
  key = endpoint + query
  klength = key.length
  puts "Key length = #{key.length}"
  results = CACHE[key[klength - 255..-1]]
  if !results
    puts "SPARQL query to DBPedia not in cache"
    sparql = SPARQL::SPARQLWrapper.new(endpoint)
    sparql.setQuery(query)
    results = sparql.query
    CACHE[key[klength - 255..-1]] = results
  end
  results
end

qs="
SELECT distinct  ?pred WHERE {
     ?a ?pred ?o .
}
LIMIT 100
"
endpoint="http://dbpedia.org/sparql"

# Make the same query twice to show effect of caching:

2.times {|i|
  puts "Starting SPARQL DBPedia query..."
  puts Benchmark.measure { puts sparql_query_cache(endpoint, qs) }
}