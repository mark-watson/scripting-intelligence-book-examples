require 'rubygems' # require for Ruby 1.8.6
require 'activerecord'
require 'memcache'
require 'pp'

ActiveRecord::Base.establish_connection(
  :adapter  => :mysql,
  :database => "test" 
)

class NewsArticle < ActiveRecord::Base
  @@cache = MemCache::new('localhost:11211', :namespace => 'news_articles')
  def self.find_cache id
    article = @@cache[id]
    if !article
      puts "id #{id} not in cache"
      article = NewsArticle.find(id)
      @@cache.set(id, article, 180)
    end
    article
  end
  def update_cache
    update # call base class method
    @@cache.set(self.id, self, 180)
  end
end

article_1 = NewsArticle.find_cache(1)
article_2 = NewsArticle.find_cache(2)
puts "#{article_1.url} #{article_2.url}"

article_1 = NewsArticle.find_cache(1)
article_2 = NewsArticle.find_cache(2)
puts "#{article_1.url} #{article_2.url}"

article_1.url = "http://test.com/bigwave" + rand(999).to_s
article_1.update_cache

article_1 = NewsArticle.find_cache(1)
puts "modified url for first article: #{article_1.url}"

