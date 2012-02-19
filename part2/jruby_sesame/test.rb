include Java
require "rsesame.jar"
include_class "SesameWrapper"

tsm = SesameWrapper.new
tsm.load_n3("../data/rdfs_business.n3")

# Use duck typing: define a class implementing the method "triple" :
class TestCallback
  def triple result_list # called for each SPARQL query result
    puts "Matching subject: #{result_list[0]}\n         predicate: #{result_list[1]}"
  end
end

callback = TestCallback.new

sparql_query =
"PREFIX kb:  <http://knowledgebooks.com/test#>
SELECT  ?subject ?predicate ?object2
WHERE {
    ?subject ?predicate kb:Amazon .
}"

tsm.query(sparql_query, callback)  
