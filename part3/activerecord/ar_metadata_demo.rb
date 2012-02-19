require 'rubygems' # needed for Ruby 1.8.*
require 'activerecord'
require 'pp'
    
ActiveRecord::Base.establish_connection(:adapter  => :mysql, :database => "test")

class Place < ActiveRecord::Base
  belongs_to :news_article
end

#pp (Place.public_methods - Object.public_methods).sort

pp Place.table_name
pp Place.column_names
pp Place.count
