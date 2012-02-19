require 'rubygems' # needed for Ruby 1.8.6
require 'scrubyt'
require 'activerecord'

ActiveRecord::Base.establish_connection(:adapter => :postgresql, :database => 'test', :username => 'postgres', :password => 'myself')

class ScrapedRecipe < ActiveRecord::Base
end

class ScrapedRecipeIngredient < ActiveRecord::Base
end
 
def recipe_to_db(recipe_url)
  puts "** processing: #{recipe_url}"
  recipe = Scrubyt::Extractor.define do
    fetch "http://cjskitchen.com/#{recipe_url}" 
    recipe2 '//table/tr' do
      title         "/td[1]/h2"
      description   "/td[1]"
      amount        "/td[2]"
    end
    recipe2 '//body' do
      directions "/"
    end
  end
  
  index = recipe_url.index('=')
  puts "recipe_url = #{recipe_url} and index=#{index}"
  recipe_id = recipe_url[index+1..-1].to_i
  a_recipe = ScrapedRecipe.new(:recipe_id => recipe_id, :base_url => 'http://cjskitchen.com')
  
  recipe.to_hash.each {|hash|
    if hash[:title]
      a_recipe.recipe_name = hash[:title]
    elsif hash[:directions]
      index = hash[:directions].index('Number of people served by the recipe:')
      a_recipe.directions = hash[:directions][index..-1] if index
    elsif hash[:description]
      ingredient = ScrapedRecipeIngredient.new(:description => hash[:description], :amount => hash[:amount], :scraped_recipe_id => recipe_id)
      ingredient.save!
    end
  }
  a_recipe.save!
end
 
recipes = Scrubyt::Extractor.define do
  fetch 'http://cjskitchen.com/'
 
  recipe '//table/tr/td' do
    recipe_url         "//a/@href"
  end
end
 
recipes.to_hash.each {|hash|
  recipe_to_db(hash[:recipe_url]) if hash[:recipe_url]
  sleep(1) # wait one second between page fetches
}
  
