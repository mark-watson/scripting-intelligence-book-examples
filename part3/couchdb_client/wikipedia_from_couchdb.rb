require 'rubygems' # required for Ruby 1.8.6
require 'couchrest'
require 'yaml'
require 'text-resource'

require 'pp'


db = CouchRest.database!("http://127.0.0.1:5984/wikipedia_semantics")
ids = db.documents['rows'].collect {|row| row['id']}

ids.each {|id|
  doc = db.get(id)
  puts doc['source_uri']
  puts doc['summary']
  puts doc['sentiment_rating']
  pp YAML.load(doc['human_names'])
  pp YAML.load(doc['place_names'])
  puts doc['plain_text']
}
