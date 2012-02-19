require 'rubygems'
require 'jruby/lucene'
require 'pp'

lucene = Lucene.new('./temp_data')
pp lucene.search(ARGV[0]) if ARGV.length > 0
