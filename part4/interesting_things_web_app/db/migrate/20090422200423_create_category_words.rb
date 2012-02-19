class CreateCategoryWords < ActiveRecord::Migration
  def self.up
    create_table :category_words do |t|
      t.string :word_name
      t.string :category_name
      t.float :importance
    end
    Dir.entries("db/categories_as_text").each {|fname|
      if fname[-4..-1] == '.txt'
          File.open("db/categories_as_text/#{fname}").each_line {|line|
            word, score = line.split
            CategoryWord.create(:word_name => word, :category_name => fname[0..-5], :importance => score.to_f * 0.1)
          }
      end
    }
    add_index :category_words, :word_name
  end

  def self.down
    drop_table :category_words
  end
end
