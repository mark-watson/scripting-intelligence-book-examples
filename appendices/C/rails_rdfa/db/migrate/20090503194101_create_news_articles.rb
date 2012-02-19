class CreateNewsArticles < ActiveRecord::Migration
  def self.up
    create_table :news_articles do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :news_articles
  end
end
