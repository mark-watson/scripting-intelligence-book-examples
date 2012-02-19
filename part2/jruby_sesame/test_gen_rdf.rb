include Java
require "rsesame.jar"
include_class "SesameWrapper"
require 'pp'

tsm = SesameWrapper.new
tsm.load_n3("/Users/markw/Documents/Writing/allegrograph_book/java_practical_semantic_web/testdata/gen_rdf.nt")

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
