require "rubygems"
require "sparql_client"
#require "sparql_results"
require "json"

# Simple REST client for SPARQL protocol
# Status: unfinished transliteration of Pythong original. XML/JSON detail 
# to be pushed down into library code.          danbrickley@gmail.com

#qs = "SELECT DISTINCT ?name ?url WHERE {  [ <http://xmlns.com/foaf/0.1/name> ?name ; <http://xmlns.com/foaf/0.1/homepage> ?url ]  }"
qs="SELECT ?s ?p ?o WHERE {
  ?s ?p ?o .
}
LIMIT 10"
#good endpoint:
#endpoint = "http://sandbox.foaf-project.org/2008/foaf/ggg.php"
#good endpoint:
#endpoint="http://data.linkedmdb.org/sparql"
#good endpoint:
endpoint="http://www4.wiwiss.fu-berlin.de/is-group/sparql"
#good: world factbook:
#endpoint="http://www4.wiwiss.fu-berlin.de/factbook/sparql"

## world factobook query to get all country names:

qs2="SELECT DISTINCT ?name
WHERE { ?name a <http://www4.wiwiss.fu-berlin.de/factbook/ns#Country> }
ORDER BY ?name"

## world factbook query to get some data for Afganistan:
qs3="SELECT DISTINCT ?p ?o
WHERE { <http://www4.wiwiss.fu-berlin.de/factbook/resource/Afghanistan> ?p ?o . }
LIMIT 5"

#format = SPARQL::JSON  # note: sandbox ARC server is truncating string values
format = SPARQL::XML
#format = SPARQL::N3  # note: sandbox ARC server is truncating string values

sparql = SPARQL::SPARQLWrapper.new(endpoint)
#sparql.addDefaultGraph("http://danbri.org/foaf.rdf")
sparql.query_string = qs
puts " **** Query string: \n" + qs + "\n\n"
begin
    #sparql.setReturnFormat(format)
    ret = sparql.query()

puts " **** format=#{format}"
puts "**** ret=#{ret.response}"

            puts "Results: #{ret._convertXML().class}"    
            doc=ret._convertXML() 
            puts doc.each_element('//result') {|row|  
	           puts "ROW: "+ row.to_s 
            }
rescue
   puts "It all went horribly wrong: #{$!}"
end

