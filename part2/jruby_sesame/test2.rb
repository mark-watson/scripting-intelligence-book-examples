include Java
require "rsesame.jar"
include_class "SesameWrapper"
require 'pp'

tsm = SesameWrapper.new
tsm.load_n3("../data/test.n3")

# Use duck typing: define a class implementing the method "triple" :
class TestCallback
  def triple result_list # called for each SPARQL query result
    pp result_list
  end
end

callback = TestCallback.new

puts "\n\nTest 1: print all triples in data store:"
sparql_query =
"SELECT  ?subject ?predicate ?object2
WHERE {
    ?subject ?predicate ?object2 .
}"
tsm.query(sparql_query, callback)  


puts "\n\nTest 2: print all triples in data store concerning books and their publishers:"
sparql_query =
"PREFIX sw:  <http://nadeen.edu/sw#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT  ?publisher ?publisher_label ?book ?book_label
WHERE {
    ?book sw:publishedBy ?publisher .
    ?publisher rdfs:label ?publisher_label .
    ?book rdfs:label ?book_label .
}"
tsm.query(sparql_query, callback)


puts "\n\nTest 3: find all subclasses of Stationary:"
sparql_query =
"PREFIX sw:  <http://nadeen.edu/sw#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT  ?typeofstationary ?label
WHERE {
    ?typeofstationary rdfs:type sw:Stationary .
    ?typeofstationary rdfs:label ?label .
}"
tsm.query(sparql_query, callback)


