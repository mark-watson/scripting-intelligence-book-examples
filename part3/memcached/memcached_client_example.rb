require 'rubygems'
require 'memcache'
require 'pp'

cache = MemCache::new('localhost:11211',
                     :debug => false,
                     :namespace => 'ruby_test')

cache['Ruby'] = ["http://www.ruby-lang.org/en/"]

puts "Ruby Web Sites:"
pp cache['Ruby']

cache['Ruby'] = cache['Ruby'] << "http://www.ruby-lang.org/en/libraries/"

puts "Ruby Web Sites:"
pp cache['Ruby']


# symbol keys are converted to strings:
cache[:a_symbol_key] = [1, 2, 3.14159]

pp cache['a_symbol_key']

# values can be any Ruby object that can be serialized:
cache["an_array"] = [0, 1, 2, {'cat' => 'dog'}, 4]

value = cache["an_array"]
puts value[0]
p value[3]

# a key that is not in the cache returns nil:

p cache['no_match'].class  # returns instance of NilClass
