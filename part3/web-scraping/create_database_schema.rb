# as in the Chapter 8 examples:

require 'rubygems'
require 'activerecord'

ActiveRecord::Base.establish_connection(:adapter => :postgresql, :database => 'test', :username => 'postgres', :password => 'myself')

ActiveRecord::Schema.define do 
  create_table :scraped_recipes do |t|
    t.string :base_url # will be http://knowledgebooks.com or http://cjskitchen.com
    t.integer :recipe_id
    t.string :recipe_name
    t.text :directions
  end

  create_table :scraped_recipe_ingredients do |t|
    t.string :description
    t.string :amount
    t.integer :scraped_recipe_id
  end
end
