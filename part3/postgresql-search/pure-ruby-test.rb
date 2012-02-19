require 'rubygems' # needed for Ruby 1.8.6
require 'postgres-pr/connection'
require 'pp'

conn = PostgresPR::Connection.new('search_test', 'postgres')

results = conn.query("select id, title from articles where to_tsvector(contents) @@ to_tsquery('fish')")
results.rows.each {|result| pp result}

conn.query("insert into articles values (3, 'Watson Wins Championship', 'Mark Watson won the ping pong championship for the second year in a row')")

results = conn.query("select id, title from articles where to_tsvector(contents) @@ to_tsquery('ping & pong')")
pp results.rows

# get rid of the new row I just added:
conn.query('delete from articles where id=3')

# close the socket connection to PostgreSQL:
conn.close
