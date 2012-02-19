## test code for cleanuping up text

# note: do not use: str.gsub(/<\/?[^>]*>/, "")
#       because improper HTML causes bad results

require 'rubygems'
require 'action_controller'

sanitizer = HTML::FullSanitizer.new

puts sanitizer.sanitize("<h1>test 1 2 3</h1>")
puts sanitizer.sanitize("<h1>test 1 2 3</h1>regular text")
puts sanitizer.sanitize("<h1>test 1 2 3</h1>\nregular text")


def clean_up text
  def remove_extra_whitespace text
    puts text
    text = text.strip.gsub("\n", ' ').gsub("\t", ' ')
    5.times { text.gsub!('  ', ' ') }
    text
  end
  text.gsub!('>', '> ')
  if text.index('<')
    text = HTML::FullSanitizer.new.sanitize(text)
  end
  remove_extra_whitespace(text)
end

#puts clean_up("<h1>header 1</h1>This   is\n <b>a test \t 1 2 3. ")