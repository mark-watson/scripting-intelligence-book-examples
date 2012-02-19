require 'rubygems' # needed for Ruby 1.8.6
require 'activerecord'
require 'geohash' # requires Ruby 1.8.6
require 'benchmark'
require 'pp'

ActiveRecord::Base.establish_connection(
  :adapter  => :mysql,
  :database => 'test',
  :username => 'root' 
)

# Schema:
# create table locations (id integer, name varchar(30), geohash char(6), lat float, lon float);
#class Location < ActiveRecord::Base
#end

def find_near_using_sql lat, lon
  sql = "select * from locations where (lat between #{lat - 0.01} and #{lat + 0.01}) and (lon between #{lon - 0.01} and #{lon + 0.01})"
  ActiveRecord::Base.connection.execute(sql).num_rows
end

def sql_test
  100.times {|n|
    lat =  39.0 + 0.01 * rand(100).to_f
    lon = -77.0 + 0.01 * rand(100).to_f
    find_near_using_sql(lat, lon)
  }
end

def find_near_using_geohash lat, lon
  geohash = GeoHash.encode(lat, lon)[0..4]
  sql = "select * from locations where geohash = '#{geohash}'"
  count = 0
  ActiveRecord::Base.connection.execute(sql).each {|row|
    lat2 = row[3].to_f
    lon2 = row[4].to_f
    count += 1 if lat2 > (lat - 0.01) && lat2 < (lat + 0.01) && lon2 > (lon - 0.01) && lon2 < (lon + 0.01)
  }
  count
end

def geohash_test
  100.times {|n|
    lat =  39.0 + 0.01 * rand(100).to_f
    lon = -77.0 + 0.01 * rand(100).to_f
    find_near_using_geohash(lat, lon)
  }
end

puts Benchmark.measure {sql_test}
puts Benchmark.measure {geohash_test}