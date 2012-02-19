require "rubygems"
require "sparql_client"

qs="
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX db: <http://localhost:2020/resource/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX map: <file:/Users/markw/Desktop/d2r-server-0.6/mapping.n3#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX vocab: <http://localhost:2020/vocab/resource/>

SELECT DISTINCT ?recipe_name ?ingredient_name ?ingredient_amount WHERE {
  ?recipe_row vocab:scraped_recipes_recipe_name ?recipe_name .
  ?recipe_row vocab:scraped_recipes_id ?recipe_id .
  ?ingredient_row vocab:scraped_recipe_ingredients_scraped_recipe_id ?recipe_id .
  ?ingredient_row vocab:scraped_recipe_ingredients_description ?ingredient_name .
  ?ingredient_row vocab:scraped_recipe_ingredients_amount ?ingredient_amount .
}
LIMIT 1
"
endpoint="http://localhost:2020/sparql"
sparql = SPARQL::SPARQLWrapper.new(endpoint)
sparql.setQuery(qs)
ret = sparql.query()
puts ret.response
