class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :uri, :null => false
      t.string :original_source_uri
      t.string :summary
      t.text :plain_text  # use a Sphinx index on this attribute
    end
  end

  def self.down
    drop_table :documents
  end
end
