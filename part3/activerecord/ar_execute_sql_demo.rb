require 'rubygems' # needed for Ruby 1.8.*
require 'activerecord'
require 'pp'
    
ActiveRecord::Base.establish_connection(:adapter  => :mysql, :database => "test")

class Place < ActiveRecord::Base
  belongs_to :news_article
end

sql = "select * from places"
results = ActiveRecord::Base.connection.execute(sql)
pp results.fetch_fields.collect {|f| f.name}
results.each {|result| pp result}


sql = "select name, news_article_id from places"
results = ActiveRecord::Base.connection.execute(sql)
pp results.fetch_fields.collect {|f| f.name}
results.each {|result| pp result}
