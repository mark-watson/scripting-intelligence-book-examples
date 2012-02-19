require 'rubygems' # needed for Ruby 1.8.6
require 'scrubyt'
require 'pp'
  
recipes = Scrubyt::Extractor.define do
  fetch 'http://cjskitchen.com/'
 
  recipe '//table/tr/td' do
    recipe_url         "//a/@href"
    recipe_text         "//a"
  end
end
 
recipes.to_hash.each {|hash|
  if hash[:recipe_url]
    puts "#{hash[:recipe_text]} link: http://cjskitchen.com/#{hash[:recipe_url]}"
  end
}
  
# sample getting second recipe type page details:

recipe = Scrubyt::Extractor.define do
  fetch 'http://cjskitchen.com/printpage.jsp?recipe_id=1699880'
 
  recipe2 '//table/tr' do
    title         "/td[1]/h2"
    description   "/td[1]"
    amount        "/td[2]"
  end
  recipe2 '//body' do
    directions "/"
  end
end

recipe.to_hash.each {|hash|
  if hash[:title]
    puts "Recipe: #{hash[:title]}\n"
  elsif hash[:directions]
    index = hash[:directions].index('Number of people served by the recipe:')
    puts hash[:directions][index..-1] if index
  elsif hash[:description]
    puts "  #{hash[:description]} : #{hash[:amount]}"
  end
}

