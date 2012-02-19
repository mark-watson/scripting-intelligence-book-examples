PLACE_STRING_SYMBOLS = [:city, :us_city, :country_capital, :country, :us_state]
PLACE_NAMES = {}
open('db/placenames.txt').readlines.each {|line|
  index = line.index(':')
  PLACE_NAMES[line[0...index].strip] = line[index+1..-1].strip
}

module Places
  class EntityExtraction
    attr_reader :place_names
    
    def initialize text = ''
      words = text.scan(/[a-zA-Z]+/)
      word_flags = []
      words.each_with_index  {|word, i|
        word_flags[i] = []
        word_flags[i] << PLACE_NAMES[word].to_sym if PLACE_NAMES[word]
      }
      # easier logic with two empty arrays at end of word flags:
      word_flags << [] << []
      @place_names = []
      place_name_buffer = []
      in_place_name = false
      word_flags.each_with_index  {|flags, i|
        place_name_symbol_in_list?(flags) ? in_place_name = true : in_place_name = false
        if in_place_name
          place_name_buffer << words[i]
        elsif !place_name_buffer.empty?
          @place_names << place_name_buffer.join(' ')
          place_name_buffer = []
        end
      }
      @place_names.uniq!
    end

    def place_name_symbol_in_list? a_symbol_list
      a_symbol_list.each {|a_symbol|
        return true if PLACE_STRING_SYMBOLS.index(a_symbol)
      }
      false
    end
  end
end

pe = Places::EntityExtraction.new('I went hiking in Sedona')
require 'pp'
pp pe.place_names
