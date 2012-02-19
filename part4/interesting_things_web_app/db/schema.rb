# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090422200423) do

  create_table "category_words", :force => true do |t|
    t.string "word_name"
    t.string "category_name"
    t.float  "importance"
  end

  add_index "category_words", ["word_name"], :name => "index_category_words_on_word_name"

  create_table "document_categories", :force => true do |t|
    t.integer "document_id"
    t.string  "category_name"
    t.boolean "set_by_user"
    t.float   "likelihood"
  end

  add_index "document_categories", ["category_name"], :name => "index_document_categories_on_category_name"

  create_table "documents", :force => true do |t|
    t.string "uri",                 :default => "", :null => false
    t.string "original_source_uri"
    t.string "summary"
    t.text   "plain_text"
  end

  create_table "similar_links", :force => true do |t|
    t.integer "doc_id_1", :null => false
    t.integer "doc_id_2", :null => false
    t.float   "strength", :null => false
  end

end
