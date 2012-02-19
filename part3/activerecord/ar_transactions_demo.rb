require 'rubygems' # needed for Ruby 1.8.*
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

## assume that the database is setup using the previous chapter 8 examples:

wave_article = NewsArticle.find(1)
mark = Person.find(1)
sedona = Place.find(1)

pp wave_article
pp mark
pp sedona

mark.name = "Mark Watson"
sedona.name = "Sedona, Arizona"

ActiveRecord::Base.transaction do
  mark.save!
  sedona.save!
end

mark.transaction do
  mark.save!
end

Person.transaction do
  mark.save!
end
