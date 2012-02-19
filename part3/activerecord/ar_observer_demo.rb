require 'rubygems' # needed for Ruby 1.8.*
require 'activerecord'

ActiveRecord::Base.establish_connection(:adapter  => :mysql, :database => "test")

class Place < ActiveRecord::Base
  belongs_to :news_article
end
class Person < ActiveRecord::Base
  belongs_to :news_article
end

class MyObserver < ActiveRecord::Observer
  observe :place, :person
  def before_save(model)
    puts "** Before saving #{model}"
  end
  def after_save(model)
    puts "** After saving #{model}"
  end
end  

ActiveRecord::Base.observers << MyObserver
ActiveRecord::Base.instantiate_observers

puts "Create a new in-memory place:"
place = Place.new(:name => 'Arizona')
puts "Save the new in-memory place to the database:"
place.save!
puts "Destroy the place object and remove from database:"
place.destroy

puts "Create a new in-memory person:"
brady = Person.new(:name => 'Brady')
puts "Save the new in-memory person to the database:"
brady.save!
puts "Destroy the person object and remove from database:"
brady.destroy
