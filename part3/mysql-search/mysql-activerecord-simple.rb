require 'rubygems' # needed for Ruby 1.8.6
require 'activerecord'
require 'pp'

# my monkey patching:
class ActiveRecord::Base
  def self.text_search_by_column column_name, query
    sql = "select * from " + self.table_name + " where match(" + column_name + ") against ('" + query +"' in boolean mode)"
    result = []
    ActiveRecord::Base.connection.execute(sql).each {|r| result << r}
    result
  end
end

ActiveRecord::Base.establish_connection(
  :adapter  => :mysql,
  :database => 'test',
  :username => 'root' 
)

class News < ActiveRecord::Base
  set_table_name 'news'
end

result = News.text_search_by_column('contents', '+organic')
pp result