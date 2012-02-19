require 'rubygems' # needed for Ruby 1.8.6
require 'activerecord'
require 'pp'

# my monkey patching:
class ActiveRecord::Base
  @@tables = nil
  def self.text_search_by_column column_name, query
    sql = "select * from " + self.table_name + " where to_tsvector(" + column_name + ") @@ to_tsquery('" + query +"')"
    ActiveRecord::Base.connection.execute(sql).rows
  end
  def self.text_search query
    @@tables = get_searchable_columns if !@@tables
    sql = "select * from " + self.table_name + " where to_tsvector(" + @@tables + ") @@ to_tsquery('" + query +"')"
    puts sql
    ActiveRecord::Base.connection.execute(sql).rows
  end
  private
  def self.get_searchable_columns
    ret = []
    self.column_names.each {|column_name|
      begin
        sql = "select * from " + self.table_name + " where to_tsvector(" + column_name + ") @@ to_tsquery('fish') limit 1"
        ActiveRecord::Base.connection.execute(sql).rows
        ret << column_name
      rescue
      end
    }
    ret.join(' || ')
  end
end

ActiveRecord::Base.establish_connection(
  :adapter  => :postgresql,
  :database => 'search_test',
  :username => 'postgres' 
)

class Article < ActiveRecord::Base
end

#pp (Article.public_methods - Object.public_methods).sort

#pp Article.text_search_by_column('contents', 'fish')

pp Article.text_search('watson')  # 'fish')
pp Article.text_search(fish')

pp Article.get_searchable_columns

# select * from articles where to_tsvector(contents)  @@ to_tsquery('fish|tennis')
