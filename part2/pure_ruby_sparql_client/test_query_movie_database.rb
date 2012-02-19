require "sparql_client"
require 'pp'

# any movies with "Fistful of Dollars" in title:

ENDPOINT="http://data.linkedmdb.org/sparql"

def search_movies search_phrase  
  qs="SELECT ?title ?actor WHERE {
    ?s ?p ?title FILTER regex(?title, \"#{search_phrase}\") .
    ?s <http://data.linkedmdb.org/resource/movie/performance_actor> ?actor .
  }
  LIMIT 20"
  sparql = SPARQL::SPARQLWrapper.new(ENDPOINT)
  sparql.query_string = qs
  ret = sparql.query
  xmldoc = ret.convertXML
  xmldoc.each_element('//result') {|result|
    title = actor = nil
    result.each_element("binding") {|binding|
      binding_name = binding.attribute('name').to_s.strip
      binding.each_element('literal') {|literal|
        actor = literal.text if binding_name == 'actor'
        title = literal.text if binding_name == 'title'
      }
    }
    puts "#{title}\t:\t#{actor}" if title && actor
  }
end

### test:
search_movies("Fistful of Dollars")

# properties and objects for one movie found with the last query:
qs="SELECT ?p ?o WHERE {
  <http://data.linkedmdb.org/resource/film_series/71> ?p ?o
}
LIMIT 10"
