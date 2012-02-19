require 'rubygems' # needed for Ruby 1.8.*
require 'activerecord'

ActiveRecord::Base.establish_connection(:adapter  => :mysql, :database => "test")

# enable logging of all events:
ActiveRecord::Base.logger = Logger.new(STDOUT)

class NewsArticle < ActiveRecord::Base
  has_many :people
  has_many :places
end

class Place < ActiveRecord::Base
  belongs_to :news_article
end
class Person < ActiveRecord::Base
  belongs_to :news_article
end

puts "Fetch news article from row 1 of database:"
news = NewsArticle.find(1)
puts "Access all people in news article:"
people = news.people
puts "Access all places in news article:"
places = news.places

# now turn off lazy loading for people:

puts "load a news article with lazy loading turned off:"
news2 = NewsArticle.find(1, :include => [:people, :places])