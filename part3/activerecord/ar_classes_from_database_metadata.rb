require 'rubygems' # required for Ruby 1.8.x
require 'activerecord'
    
ActiveRecord::Base.establish_connection(
  :adapter  => :mysql,
  :database => "test" 
)

class NewsArticle < ActiveRecord::Base
  has_many :people
  has_many :places
end

class Person < ActiveRecord::Base
  belongs_to :news_article
end

class Place < ActiveRecord::Base
  belongs_to :news_article
end

require 'pp'

NewsArticle.new(:url => 'http://test.com/bigwave',
                :title => 'Tidal Wave Misses Hawaii',
                :summary => 'Tidal wave missed Hawaii by 500 miles',
                :contents => 'A large tidal wave travelled across the pacific, missing Hawaii by 500 miles').save

pp NewsArticle.find(:all)

wave_article = NewsArticle.find(1)
# or, get the same article, overwriting the value in the variable wave_article:
title = 'Tidal Wave Misses Hawaii'
wave_article = NewsArticle.find(:all, :conditions => ['title = ?', title])

pp (wave_article.public_methods - Object.public_methods).sort

mark = Person.new(:name => "Mark")
#mark.save

sedona = Place.new(:name => "Sedona Arizona")
#sedona.save

wave_article[0].places << sedona
wave_article[0].people << mark

#wave_article.save

