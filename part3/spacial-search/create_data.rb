require 'rubygems' # needed for Ruby 1.8.6
require 'activerecord'
require 'geohash' # requires Ruby 1.8.6
require 'pp'

ActiveRecord::Base.establish_connection(
  :adapter  => :mysql,
  :database => 'test',
  :username => 'root' 
)

# Schema:
# create table locations (id integer, name varchar(30), geohash char(6), lat float, lon float);
class Location < ActiveRecord::Base
end

NUM = 50000 # number of database rows to create with random data

# Note: this is inefficient: should be done in a transaction is NUM is very large:

NUM.times {|n|
  lat =  39.0 + 0.01 * rand(100).to_f
  lon = -77.0 + 0.01 * rand(100).to_f
  geohash = GeoHash.encode(lat, lon)
  Location.new(:name => "location name #{n}", :geohash => geohash[0..4], :lat => lat, :lon => lon).save!
}

# Note: out of 50K records, I have 9036 unique geohash values

#pp Location.find(:all)