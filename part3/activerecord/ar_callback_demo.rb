require 'rubygems' # needed for Ruby 1.8.*
require 'activerecord'
    
ActiveRecord::Base.establish_connection(
  :adapter  => :mysql,
  :database => "test" 
)

class Place < ActiveRecord::Base
  belongs_to :news_article
  before_create :monitor_before_place_creation
  after_create :monitor_after_place_creation
  before_save :monitor_before_place_save
  after_save :monitor_after_place_save
  before_destroy :monitor_before_place_destroy
  after_destroy :monitor_after_place_destroy

private  
  def monitor_before_place_creation; puts 'monitor_before_place_creation'; end
  def monitor_after_place_creation;  puts 'monitor_after_place_creation';  end
  def monitor_before_place_save;     puts 'monitor_before_place_save';     end
  def monitor_after_place_save;      puts 'monitor_after_place_save';      end
  def monitor_before_place_destroy;  puts 'monitor_before_place_destroy';  end
  def monitor_after_place_destroy;   puts 'monitor_after_place_destroy';   end
end

puts "Create a new in-memory place:"
place = Place.new(:name => 'Arizona')
puts "Save the new in-memory place to the database:"
place.save!
puts "Destroy the object and remove from database:"
place.destroy
