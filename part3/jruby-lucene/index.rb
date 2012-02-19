require 'rubygems'
require 'jruby/lucene'
require 'pp'

lucene = Lucene.new('./temp_data')
count = 1
begin
  count = File.read('./temp_data/count.txt').strip.to_i
  puts "count = #{count}"
rescue
  puts "Could not open ./temp_data/count.txt"
  File.open('./temp_data/count.txt', 'w') {|f| f.puts('1')}
end

lucene.add_documents(ARGV.collect {|z| count += 1; [count, z]})

File.open('./temp_data/count.txt', 'w') {|f| f.puts(count)}
