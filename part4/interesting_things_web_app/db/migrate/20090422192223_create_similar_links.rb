class CreateSimilarLinks < ActiveRecord::Migration
  def self.up
    create_table :similar_links do |t|
      t.integer :doc_id_1, :null => false
      t.integer :doc_id_2, :null => false
      t.float   :strength, :null => false
    end
  end

  def self.down
    drop_table :similar_links
  end
end
