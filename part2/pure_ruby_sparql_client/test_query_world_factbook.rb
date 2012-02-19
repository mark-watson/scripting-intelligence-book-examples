require "rubygems"
require "sparql_client"
require 'pp'

qs="SELECT ?name ?capital ?population  WHERE {
  ?country
   <http://www4.wiwiss.fu-berlin.de/factbook/ns#countryname_conventionalshortform>
   ?name .
  ?country
   <http://www4.wiwiss.fu-berlin.de/factbook/ns#capital_name>
   ?capital .
  ?country
   <http://www4.wiwiss.fu-berlin.de/factbook/ns#population_total>
   ?population .
}
LIMIT 30"


qs="prefix wf: <http://www4.wiwiss.fu-berlin.de/factbook/ns#>
select ?name ?capital ?population  where {
  ?country
   wf:countryname_conventionalshortform
   ?name .
  ?country
   wf:capital_name
   ?capital .
  ?country
   wf:population_total
   ?population .
}
limit 30"

endpoint="http://www4.wiwiss.fu-berlin.de/factbook/sparql"

sparql = SPARQL::SPARQLWrapper.new(endpoint)
sparql.query_string = qs
puts " **** Query string: \n" + qs + "\n\n"
begin
  ret = sparql.query
  puts ret.response
  xmldoc = ret.convertXML
  xmldoc.each_element('//result') {|result|
    name = capital = population = nil
    result.each_element("binding") {|binding|
      binding_name = binding.attribute('name').to_s.strip
      binding.each_element('literal') {|literal|
        name = literal.text       if binding_name == 'name'
        capital = literal.text    if binding_name == 'capital'
        population = literal.text if binding_name == 'population'
      }
    }
    puts "#{name}\t : #{capital}\t : #{population}" if name && capital && population
  }
end
