require 'rubygems' # only for Ruby 1.8.x
require 'calais_client'
s = "Hillary Clinton and Barack Obama campaigned in Texas. Both want to live  in the White House. Pepsi sponsored both candidates." 
cc = CalaisClient::OpenCalaisTaggedText.new(s)
require 'pp'
#pp cc
pp cc.get_tags