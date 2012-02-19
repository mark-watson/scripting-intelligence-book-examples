require 'rubygems' # needed for Ruby 1.8.6
require 'activerecord'
require 'stemmer'
require 'graphviz'
require 'pp'

ActiveRecord::Base.establish_connection(:adapter => :postgresql, :database => 'test', :username => 'postgres')

class ScrapedRecipe < ActiveRecord::Base
  has_many :scraped_recipe_ingredients
  attr_accessor :name_word_stems
  attr_accessor :ingredient_word_stems
  @@stop_words = ['and', 'the', 'with', 'frozen', '&amp;', 'salt', 'pepper']
  def stem_words
    @name_word_stems = self.recipe_name.downcase.scan(/\w+/).collect {|word| word.stem} - @@stop_words
    @ingredient_word_stems = self.scraped_recipe_ingredients.inject([]) {|all, ing| all = ing.description.downcase.scan(/\w+/).each {|s| s.stem}}  - @@stop_words
  end
  def compare_name_to another_scraped_recipe
    compare_helper(self.name_word_stems, another_scraped_recipe.name_word_stems)
  end
  def compare_ingredients_to another_scraped_recipe
    compare_helper(self.ingredient_word_stems, another_scraped_recipe.ingredient_word_stems)
  end
  private
  def compare_helper list1, list2
    2.0 * (list1 & list2).length / (list1.length + list2.length + 0.01)
  end
end

class ScrapedRecipeIngredient < ActiveRecord::Base
end

$recipes = ScrapedRecipe.find(:all)
$ingredients = ScrapedRecipeIngredient.find(:all)

$recipes[0].stem_words
pp $recipes[0]
pp $recipes[0].name_word_stems
pp $recipes[0].ingredient_word_stems

# stem words in all recipes:
$recipes.each {|recipe| recipe.stem_words}

# generate both RDF triples and GraphZiz dot file output:

fout = File.open('recipes.rdf', 'w')
fout.puts('@prefix kb: <http://knowledgebooks.com/test#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .

kb:Recipe a rdfs:Class;
     rdfs:label "Recipe".

kb:similarRecipeName a rdf:Property ;
     rdfs:domain kb:Recipe;
     rdfs:range kb:Recipe .

kb:similarRecipeIngredients a rdf:Property ;
     rdfs:domain kb:Recipe;
     rdfs:range kb:Recipe .

kb:recipeName a rdf:Property;
     rdfs:domain kb:Recipe;
     rdfs:range <http://www.w3.org/2001/XMLSchema#stringstring> .
     
')
     
g = GraphViz::new("G", "output" => 'dot')
g["rankdir"] = "LR"
g.node["shape"] = "ellipse"
#g.edge["arrowhead"] = "normal"

def get_display_name a_recipe
  rn = a_recipe.recipe_name.strip.gsub(' ','_').gsub("'s", "").gsub("&amp;", "and").gsub('(','').gsub(')','').gsub(',','').gsub('-','')
  if a_recipe.base_url.index('cjskitchen')
    rn = 'cjskitchen__' + rn
  else
    rn = 'cookingspace__' + rn
  end
  rn
end

def get_recipe_full_uri a_recipe
  return "<#{a_recipe.base_url}/printpage.jsp?recipe_id=#{a_recipe.recipe_id}> " if a_recipe.base_url.index('cjskitchen')
  "<#{a_recipe.base_url}/site/show_recipe/#{a_recipe.recipe_id}> " if a_recipe.base_url.index('cookingspace')
end

num = $recipes.length
num.times {|i|
  # declare that full URI to recipe is a kb:Recipe:
  fout.puts(get_recipe_full_uri($recipes[i]))
  fout.puts("  a kb:Recipe ;")
  # add the recipe name:
  fout.puts("  kb:recipeName \"#{$recipes[i].recipe_name}\" .")
  
  num.times {|j|
    if j > i
      rn1 = get_display_name($recipes[i])
      rn2 = get_display_name($recipes[j])
      name_similarity = $recipes[i].compare_name_to($recipes[j])
      ingredients_similarity = $recipes[i].compare_ingredients_to($recipes[j])
      if name_similarity > 0.64
        # add GraphViz nodes and links:
        g.add_node(rn1)
        g.add_node(rn2)
        g.add_edge(rn1, rn2, :arrowhead => "none", :style => "dotted", :label => "name: #{(100.0*name_similarity).to_i}" )
        # write on N3 RDF:
        fout.puts("#{get_recipe_full_uri($recipes[i])} kb:similarRecipeName #{get_recipe_full_uri($recipes[j])} .")
        fout.puts("#{get_recipe_full_uri($recipes[j])} kb:similarRecipeName #{get_recipe_full_uri($recipes[i])} .")
      end
      if ingredients_similarity > 0.63
        # add GraphViz nodes and links:
        g.add_node(rn1)
        g.add_node(rn2)
        g.add_edge(rn1, rn2, :arrowhead => "none", :style => "dashed", :label => "ingredient: #{(100.0*ingredients_similarity).to_i}" )
        # write on N3 RDF:
        fout.puts("#{get_recipe_full_uri($recipes[i])} kb:similarRecipeIngredients #{get_recipe_full_uri($recipes[j])} .")
        fout.puts("#{get_recipe_full_uri($recipes[j])} kb:similarRecipeIngredients #{get_recipe_full_uri($recipes[i])} .")
      end
      if name_similarity > 0.15 || ingredients_similarity > 0.25
        puts "#{$recipes[i].recipe_name}  vs. #{$recipes[j].recipe_name}  : #{name_similarity}   #{ingredients_similarity}"
      end
    end
  }
}
g.output(:file => "recipes.dot")
fout.close