require 'rubygems'
require "firewatir"
require 'activerecord'

require 'pp'

ActiveRecord::Base.establish_connection(:adapter => :postgresql, :database => 'test', :username => 'postgres', :password => 'myself')

class ScrapedRecipe < ActiveRecord::Base
end

class ScrapedRecipeIngredient < ActiveRecord::Base
end

def get_recipe_from_page content_html
  in_ingredients = false
  in_directions = false
  ingredients = {}
  name = ''
  directions = ''
  content_html.each_line {|line|
     line = line.strip
     if index = line.index('Recipe for:')
       index2 = line.index('</strong>')
       name = line[index+11...index2].strip
     end
     in_ingredients = false if line == "<br/>" || line.index('Directions:')
     if in_ingredients
       index = line.index(':')
       ingredients[line[0..index-1]] =
        line[index+1..-1].gsub('<br />', '').gsub('<br>','').strip if index
     end
     in_ingredients = true if line.index('Ingredients:')
     in_directions = false if line == "</tr>"
     if in_directions
       directions << line.gsub(/<\/?[^>]*>/, "") << ' '
     end
     in_directions = true if line.index('Directions:')
  }
  directions.strip!
  [name, ingredients, directions]
end

#pp get_recipe_from_page(s)

ALREADY_PROCESSED_RECIPE_NAMES = []


# open a browser
$browser = Watir::Browser.new

def process_random_recipe # return false if randomly chosen recipe has already been processed, otherwise true
  $browser.goto('http://cookingspace.com/site/show_random_recipe')
  element = $browser.element_by_xpath("//tr/td")
  text = element.innerText
  recipe_name, hash, directions =  get_recipe_from_page(element.html)
  if !ALREADY_PROCESSED_RECIPE_NAMES.index(recipe_name) # checking recipe name
    ALREADY_PROCESSED_RECIPE_NAMES << recipe_name
    recipe_id = $browser.url
    recipe_id = recipe_id[recipe_id.rindex('/')+1..-1].to_i
    a_recipe = ScrapedRecipe.new(:recipe_id => recipe_id, :base_url => 'http://cookingspace.com',
         :recipe_name => recipe_name, :directions => directions)
    a_recipe.save!
    hash.keys.each {|ingredient_description|
      ingredient = ScrapedRecipeIngredient.new(:description => ingredient_description,
          :amount => hash[ingredient_description], :scraped_recipe_id => recipe_id)
      ingredient.save! 
    }
    return true
  end
  false
end

count = 0 # quit if count gets to 10
5000.times {|iter|
  sleep(1) # wait one second between page fetches
  if process_random_recipe
    count = 0
  else
    count += 1
  end
  break if count > 10
  puts "iter = #{iter}  count = #{count}"
}
