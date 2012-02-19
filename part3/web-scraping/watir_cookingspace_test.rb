require 'rubygems'
require "firewatir"

# open a browser
browser = Watir::Browser.new

puts "Navigationg to Mark Watson's cooking site http://cookingspace.com"
browser.goto("http://cookingspace.com")

puts "Entering text 'salmon' in cookingspace.com search field:"
browser.text_field(:name, "search_text").set("salmon")

puts "Click the cookingspace.com 'search' button:"
browser.button(:name, "search").click

puts "\nContents of web page after searching for 'salmon':\n\n"
puts browser.text

# debug: printout all links on the current web page:

browser.links.each { |link| puts "\nnext link: #{link.to_s}" }

# follow the link to the 'Salmon Rice' recipe:

link = browser.link(:text, "Salmon Rice")
link.click  if link

puts "\nContents of web page after clicking the 'Salmon Rice' link:\n\n"
puts browser.text

puts browser.class
require 'pp'
pp (browser.public_methods - Object.public_methods).sort
pp (browser.public_methods - Object.public_methods).length
