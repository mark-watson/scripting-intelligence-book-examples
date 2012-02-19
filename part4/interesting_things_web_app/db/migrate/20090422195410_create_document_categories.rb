class CreateDocumentCategories < ActiveRecord::Migration
  def self.up
    create_table :document_categories do |t|
      t.integer :document_id
      t.string :category_name
      t.boolean :set_by_user
      t.float :likelihood # of category being correct if not user assigned. range: [0.0, 1.0]
    end
    add_index :document_categories, :category_name
  end

  def self.down
    drop_table :document_categories
  end
end
