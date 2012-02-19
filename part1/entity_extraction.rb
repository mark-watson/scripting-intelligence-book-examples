require 'open-uri'
require 'pp'

PLACE_NAMES = Hash.new
open('data/placenames.txt').readlines.each {|line|
  index = line.index(':')
  PLACE_NAMES[line[0...index].strip] = line[index+1..-1].strip
}
### note: possible values in PLACE_NAME hash:
#         ["city", "us_city", "country_capital", "country", "us_state"]
PLACE_STRING_TO_SYMBOLS = {'city' => :city, 'us_city' => :us_city,
                           'country_capital' => :country_capital,
                           'country' => :country, 'us_state' => :us_state}
PLACE_STRING_SYMBOLS = PLACE_STRING_TO_SYMBOLS.values

FIRST_NAMES = Hash.new
open('data/firstnames.txt').readlines.each {|line|
  FIRST_NAMES[line.strip] = true
  puts "first: #{line}" if line.strip.index(' ')
}
LAST_NAMES = Hash.new
open('data/lastnames.txt').readlines.each {|line|
  LAST_NAMES[line.strip] = true
  puts "last: #{line}" if line.strip.index(' ')
}
PREFIX_NAMES = Hash.new
open('data/prefixnames.txt').readlines.each {|line|
  PREFIX_NAMES[line.strip] = true
  puts "prefix: #{line}" if line.strip.index(' ')
}

class EntityExtraction
  def initialize text = ''
    words = text.scan(/[a-zA-Z]+/)
    word_flags = Array.new(words.length)
    words.each_with_index  {|word, i|
      word_flags[i] = []
      word_flags[i] << PLACE_STRING_TO_SYMBOLS[PLACE_NAMES[word]] if PLACE_NAMES[word]
      word_flags[i] << :first_name  if FIRST_NAMES[word]
      word_flags[i] << :last_name   if LAST_NAMES[word]
      word_flags[i] << :prefix_name if PREFIX_NAMES[word]
    }

    # easier logic with two empty arrays at end of word flags:
    word_flags << [] << []

    # remove :last_name if also :first_name and :last_name token nearby:
    word_flags.each_with_index  {|flags, i|
      if flags.index(:first_name) && flags.index(:last_name)
        if word_flags[i+1].index(:last_name) || word_flags[i+2].index(:last_name)
          word_flags[i] -= [:last_name]
        end
      end
    }

    # look for middle initials in names:
    words.each_with_index {|word, i|
      if word.length == 1 && word >= 'A' && word <= 'Z'
        if word_flags[i-1].index(:first_name) && word_flags[i+1].index(:last_name)
          word_flags[i] << :middle_initial if word_flags[i].empty?
        end
      end
    }

    # discard all but :prefix_name if followed by a name:
    word_flags.each_with_index  {|flags, i|
      if flags.index(:prefix_name)
        word_flags[i] = [:prefix_name] if human_name_symbol_in_list?(word_flags[i+1])
      end
    }
    
    #discard two last name tokens in a row if the preceeding token is not a name token:
    word_flags.each_with_index  {|flags, i|
      if i<word_flags.length-2 && !human_name_symbol_in_list?(flags) && word_flags[i+1].index(:last_name) && word_flags[i+2].index(:last_name)
        word_flags[i+1] -= [:last_name]
      end
    }

    # discard singleton name flags (with no name flags on either side):
    word_flags.each_with_index  {|flags, i|
      if human_name_symbol_in_list?(flags)
        unless human_name_symbol_in_list?(word_flags[i+1]) || human_name_symbol_in_list?(word_flags[i-1])
          [:prefix_name, :first_name, :last_name].each {|name_symbol|
            word_flags[i] -= [name_symbol]
          }
        end
      end
    }

    @human_names = []
    human_name_buffer = []
    @place_names = []
    place_name_buffer = []
    in_place_name = false
    in_human_name = false
    word_flags.each_with_index  {|flags, i|
      human_name_symbol_in_list?(flags) ? in_human_name = true : in_human_name = false
      if in_human_name
        human_name_buffer << words[i]
      elsif !human_name_buffer.empty?
        @human_names << human_name_buffer.join(' ')
        human_name_buffer = []
      end
      place_name_symbol_in_list?(flags) ? in_place_name = true : in_place_name = false
      if in_place_name
        place_name_buffer << words[i]
      elsif !place_name_buffer.empty?
        @place_names << place_name_buffer.join(' ')
        place_name_buffer = []
      end
    }
    @human_names.uniq!
    @place_names.uniq!
  end
  
  def human_names
    @human_names
  end
  def place_names
    @place_names
  end

  def human_name_symbol_in_list? a_symbol_list
    a_symbol_list.each {|a_symbol|
      return true if [:prefix_name, :first_name, :middle_initial, :last_name].index(a_symbol)
    }
    false
  end

  def place_name_symbol_in_list? a_symbol_list
    a_symbol_list.each {|a_symbol|
      return true if PLACE_STRING_SYMBOLS.index(a_symbol)
    }
    false
  end
end

#ee = EntityExtraction.new('President George W. Bush left office and Barack Obama was sworn in as president and went to Florida with his family to stay at Disneyland.')
#pp ee.human_names
#pp ee.place_names
      
 