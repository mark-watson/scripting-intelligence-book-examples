require 'rubygems' # required for Ruby 1.8.6
require 'text-resource'
require 'couchrest'
require 'pp'

tr1 = PlainTextResource.new('test_data/wikipedia_Barack_Obama.txt')
tr2 = PlainTextResource.new('test_data/wikipedia_Hillary Rodham Clinton.txt')

db = CouchRest.database!("http://127.0.0.1:5984/wikipedia_semantics")

[tr1, tr2].each {|tr|
#  response = db.save_doc({
    response = db.save({
    'source_uri' => tr.source_uri,
    'summary' => tr.summary,
    'sentiment_rating' => tr.sentiment_rating.to_s,
    'human_names' => tr.human_names,
    'place_names' => tr.place_names,
    'plain_text' => tr.plain_text
    })
    puts "doc id: #{response['id']}"
}

