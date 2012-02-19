require 'test_helper'
require 'stemmer'
require 'pp'

class CategoryWordTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "make a document" do
    CategoryWord.create(:word_name => "budget".stem, :category_name => "news_economy", :importance => 8.1)
    CategoryWord.create(:word_name => "president".stem, :category_name => "news_politics", :importance => 12.1)
    doc = Document.create(:uri => "file:///tmp/test.txt", :plain_text => "Congress voted on the yearly budget. The President vowed to veto it.")
    doc.category_assigned_by_user("politics")
    doc.category_assigned_by_user("politics") # duplicate on purpose
    doc.category_assigned_by_nlp("economy", 0.4)
    doc.semantic_processing
    calculated_categories = doc.calculated_categories
    assert calculated_categories.include?("news_politics")
    assert calculated_categories.include?("news_economy")
    #pp "---calculated_categories:", calculated_categories
    calculated_summary = doc.calculated_summary
    assert calculated_summary == "The President vowed to veto it."
    #pp "--calculated_summary:", calculated_summary
    doc2 = Document.find(doc.id)
    #pp "--doc2 categories:", doc2.document_categories
    cat_names = doc2.document_categories.collect {|dc| dc.category_name}
    assert cat_names.include?("economy")
    assert cat_names.include?("politics")
    assert !cat_names.include?("sports")
  end
end
