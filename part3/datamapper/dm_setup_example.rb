require 'rubygems'  # required for Ruby 1.8.6
require 'dm-core'
require 'dm-observer'
require 'pp'

#DataMapper.setup(:default, 'sqlite3::memory:')
#DataMapper.setup(:default, "sqlite3:temp_data/dm_test.db")
DataMapper.setup(:default, 'mysql://localhost/test')
#DataMapper.setup(:default, 'postgres://localhost/test')

class NewsArticle
  include DataMapper::Resource
  property :id,       Serial
  property :url,      String
  property :title,    String
  property :summary,  String
  property :contents, Text

  has n, :people
  has n, :places
end

class Person
  include DataMapper::Resource
  property :id,   Serial
  property :name, String

  belongs_to :news_article
  # callback examples:
  before :save do
    puts "* * * Person callback: save  #{self}"
  end
  after :create do
    puts "* * * Person callback: create  #{self}"
  end
end

# Observer test:
class PersonObserver
  include DataMapper::Observer

  observe Person

  after :create do
    puts "** PersonObserver: after create #{self}"
  end
  
  before :save do
    puts "** PersonObserver: before save  #{self}"
  end

end
 
class Place
  include DataMapper::Resource
  property :id,   Serial
  property :name, String

  belongs_to :news_article
end

#DataMapper::Logger.new(STDOUT, :off)
#DataMapper::Logger.new(STDOUT, :fatal)
#DataMapper::Logger.new(STDOUT, :error)
#DataMapper::Logger.new(STDOUT, :warn)
#DataMapper::Logger.new(STDOUT, :info)
DataMapper::Logger.new(STDOUT, :debug)


# create all tables (this deletes all existing data):
DataMapper.auto_migrate!

news1 = NewsArticle.new(:url => 'http://test.com/bigwave',
                        :title => 'Tidal Wave Misses Hawaii',
                        :summary => 'Tidal wave missed Hawaii by 500 miles',
                        :contents => 'A large tidal wave travelled across the pacific, missing Hawaii by 500 miles')
news1.save

# demonstarte lazy loading of Text properties:

news_articles =  NewsArticle.all
pp news_articles

puts news_articles[0].contents
pp news_articles

# demonstrate modifying an object's attribute and persisting the change:

news_articles[0].update_attributes(:url => 'http://test.com/bigwave123')
# note: no save call is required

# demonstrate object identity:

news2 = NewsArticle.first

puts "Object equality test: #{news_articles[0] == news2}"

pp news2

# add more test data:

NewsArticle.new(:url => 'http://test.com/bigfish',
                :title => '100 pound goldfish caught',
                :summary => 'A 100 pound goldfish was caught by Mary Smith',
                :contents => 'A 100 pound goldfish was caught by Mary Smith using a bamboo fishing pole while fishing with her husband Bob').save
fishnews = NewsArticle.first(:title => '100 pound goldfish caught')

pp fishnews
pp NewsArticle.all

# using associations:

#pp (fishnews.public_methods - Object.public_methods).sort
#pp fishnews.places

mary = Person.new(:name => 'Mary Smith')
mary.save
pp mary

#fishnews.people=[mary]
fishnews.people << mary
pp mary
fishnews.save # save reqired to set news_article_id in object 'mary'

fishnews.people.build(:name => 'Bob Smith') # no save required

pp Person.all

pp fishnews
pp fishnews.people

# test transactions:

puts "\n\n\n\n"
mary.update_attributes(:name => 'Mary 1')
puts mary.name

Person.transaction {|transaction|
  puts "Inside a Person class transaction #{transaction}"
  #pp (transaction.public_methods - Object.public_methods).sort
  #transaction.begin
  mary.update_attributes(:name => 'Mary, Mary')
  puts mary.name
  transaction.rollback
}
puts mary.name

mary.update_attributes(:name => 'Mary 2')

class Person
  def transaction_example fail_flag=false
    transaction {|a_transaction|
      old_name = self.name
      self.name += ', Ruby master'
      self.save
      self.name = old_name
      self.save
    }
  end
end

# second way to do a transaction:
def transaction_example_2 a_person, fail_flag=false
  a_transaction = DataMapper::Transaction.new(a_person)
  a_transaction.begin
  DataMapper.repository(:default).adapter.push_transaction(a_transaction)

  a_person.name += ', Ruby master'
  #a_person.save

  DataMapper.repository(:default).adapter.pop_transaction
  if fail_flag
    a_transaction.rollback
  else
    a_transaction.commit
  end
end

mary.update_attributes(:name => 'Mary 2')

puts "before transaction test with no fail: #{mary.name}"
transaction_example_2(mary)
puts "after transaction test with no fail: #{mary.name}"

mary.update_attributes(:name => 'Mary 2')

puts "before transaction test with fail: #{mary.name}"
transaction_example_2(mary, true)
puts "after transaction test with fail: #{mary.name}"


#pp (repository(:default).adapter.public_methods - Object.public_methods).sort


