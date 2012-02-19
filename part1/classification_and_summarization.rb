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

HUMAN_NAME_PREFIXES_OR_ABREVIATIONS = ['Mr.', 'Mrs.', 'Ms.', 'Dr.', 'Sr.', 'Maj.', 'St.', 'Lt.', 'Sen.', 'Jan.', 'Feb.', 'Mar.', 'Apr.', "Jun.", 'Jul.', 'Aug.', 'Sep', 'Oct.', 'Nov.', 'Dec.']
DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

def sentence_boundaries text
  boundary_list = []
  start = index = 0
  current_token = ''
  text.each_char {|ch|
    if ch == ' '
      current_token = ''
    elsif ch == '.'
      current_token += ch
      if !HUMAN_NAME_PREFIXES_OR_ABREVIATIONS.member?(current_token) && 
         !DIGITS.member?(current_token[-2..-2])
        boundary_list << [start, index]
        current_token = ''
        start = index + 2
      else
        current_token += ch
      end
    elsif ['!', '?'].member?(ch)
        boundary_list << [start, index]
        current_token = ''
        start = index + 2
    else
      current_token += ch
    end
    index += 1
  }
  boundary_list
end

require 'pp'


class ClassifierAndSummarization
  def initialize
    @category_names = []
    @category_wc_hashes = []
    @noise_words = ['the', 'a', 'at', 'he', 'she', 'it']
  end
  def classify_and_summarize_plain_text text
    word_stems = text.downcase.scan(/[a-z]+/)
    scores = Array.new(@category_names.length)
    @category_names.length.times {|i|
      scores[i] = score(@category_wc_hashes[i], word_stems)
    }
    best_index = scores.index(scores.max)
    best_hash = @category_wc_hashes[best_index]
    breaks = sentence_boundaries(text)
    sentence_scores = Array.new(breaks.length)
    breaks.length.times {|i| sentence_scores[i] = 0}
    breaks.each_with_index {|sentence_break, i|
      tokens = text[sentence_break[0]..sentence_break[1]].downcase.scan(/[a-z]+/)
      tokens.each {|token| sentence_scores[i] += best_hash[token]}
      sentence_scores[i] *= 100.0 / (1 + tokens.length)
    }
    score_cutoff = 0.8 * sentence_scores.max
    summary = ''
    sentence_scores.length.times {|i|
      if sentence_scores[i] >= score_cutoff
        summary << text[breaks[i][0]..breaks[i][1]] << ' '
      end
    }
    [@category_names[best_index], summary.strip]
  end
  def train file_and_topic_list
    file_and_topic_list.each {|file, category|
      words = File.new(file).read.downcase.scan(/[a-z]+/)
      hash = Hash.new(0)
      words.each {|word| hash[word] += 1 unless @noise_words.index(word) }
      scale = 1.0 / words.length
      hash.keys.each {|key| hash[key] *= scale}
      @category_names << category
      @category_wc_hashes << hash
    }
  end
  private
  def score (hash, word_list)
    score = 0
    word_list.each {|word|
      score += hash[word]
    }
    1000.0 * score / word_list.size
  end
end



test = ClassifierAndSummarization.new
test.train([['wikipedia_text/computers.txt', "Computers"],
            ['wikipedia_text/economy.txt', "Economy"],
            ['wikipedia_text/health.txt', "Health"],
            ['wikipedia_text/software.txt', "Software"]])
require 'pp'

pp test.classify_and_summarize_plain_text("Doctors advise exercise to improve heart health. Exercise can be can be as simple as walking 25 minutes per day. A low fat diet is also known to improve heart health. A diet of fast food is not recommended.")
