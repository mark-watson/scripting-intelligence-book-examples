require 'rubygems'
require 'solr'

solr_connection = Solr::Connection.new('http://localhost:8080/solr', :autocommit => :on)
solr_connection.add(:id => 1, :text => 'The dog chased the cat up the tree')
solr_connection.add(:id => 2, :text => 'The enjoyed sitting in the tree')

solr_connection.query('tree') {|hit| pp hit}

solr_connection.update(:id => 1, :text => 'The dog went home to eat')

solr_connection.delete(1)
solr_connection.delete(2)
