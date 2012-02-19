require 'rubygems' # required for Ruby 1.8.x
require 'activerecord'
    
ActiveRecord::Base.establish_connection(
  :adapter  => :mysql,
  :database => "test" 
)

ActiveRecord::Schema.define do 
  create_table :news_articles, :force => true do |t|
    t.string :url
    t.string :title
    t.string :summary
    t.string :contents
  end

  create_table :people, :force => true do |t|
    t.string :name
    t.integer :news_article_id
  end

  create_table :places, :force => true do |t|
    t.string :name
    t.integer :news_article_id
  end
end
