require 'pp'

begin
  "1".each_char {|ch| } # fails under Ruby 1.8.x
rescue
  puts "Running Ruby 1.8.x: define each_char"
  class String
    def each_char(&code)
      self.each_byte {|ch| yield(ch.chr)}
    end
  end
end

  
def remove_noise_characters text
  def valid_character ch
    return true if ch >= 'a' and ch <= 'z'
    return true if ch >= 'A' and ch <= 'Z'
    return true if ch >= '0' and ch <= '9'
    return true if [' ','.',',',';','!'].index(ch)
    return false
  end
  ret = ''
  text.each_char {|char|
     valid_character(char) ? ret << char : ret << ' '
  }
  ret.split.join(' ')
end

VALID_WORD_HASH = Hash.new
words = File.new('big.txt').read.downcase.scan(/[a-z]+/)
words.each {|word| VALID_WORD_HASH[word] = true}
TOKENS_TO_IGNORE = ('a'..'z').collect {|tok| tok if !['a', 'i'].index(tok)} + ['li', 'h1', 'h2', 'br'] - [nil]

def remove_words_not_in_spelling_dictionary text
  def check_valid_word word
    return false if  TOKENS_TO_IGNORE.index(word)
    VALID_WORD_HASH[word] || ['.',';',','].index(word)
  end
  ret = ''
  text.gsub('.',' . ').gsub(',', ' , ').gsub(';', ' ; ').split.each {|word|
    ret << word + ' ' if check_valid_word(word)
  }
  ret.gsub('. .', '.').gsub(', ,', ',').gsub('; ;', ';')
end

#str = File.open("noise.txt").read
#s1 = remove_noise_characters(str)
#pp s1
#s2 = remove_words_not_in_spelling_dictionary(s1)
#pp s2
