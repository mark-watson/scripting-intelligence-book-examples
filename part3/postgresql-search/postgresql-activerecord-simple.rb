require 'rubygems' # needed for Ruby 1.8.6
require 'activerecord'
require 'pp'

# my monkey patching:
class ActiveRecord::Base
  def self.text_search_by_column column_name, query
    sql = "select * from " + self.table_name + " where to_tsvector(" + column_name + ") @@ to_tsquery('" + query +"')"
    ActiveRecord::Base.connection.execute(sql).rows
  end
end

ActiveRecord::Base.establish_connection(
  :adapter  => :postgresql,
  :database => 'search_test',
  :username => 'postgres' 
)

class Article < ActiveRecord::Base
end

pp Article.text_search_by_column('contents', 'fish')
