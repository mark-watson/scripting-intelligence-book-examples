require 'rubygems' # required for Ruby 1.8.6
require 'couchrest'
require 'pp'

##  from web site documentation (and gem README file):

# CouchRest.database! creates the database if it doesn't already exist:
db = CouchRest.database!("http://127.0.0.1:5984/test2")
#response = db.save_doc({'key 1' => 'value 1', 'key 2' => [1, 2, 3.14159, 'a string']})
response = db.save({'key 1' => 'value 1', 'key 2' => [1, 2, 3.14159, 'a string']})
pp "response:", response

doc = db.get(response['id'])
pp doc

# returns ids and revs of the current docs
pp db.documents
