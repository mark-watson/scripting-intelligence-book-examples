## module derived from the Chapter 3 NLP examples.
# Diferences:
#   1. category word lists, etc. are stored in a database
#   2. system intended to evolve data over time using user input

HUMAN_NAME_PREFIXES_OR_ABREVIATIONS = ['Mr.', 'Mrs.', 'Ms.', 'Dr.', 'Sr.', 'Maj.', 'St.', 'Lt.', 'Sen.', 'Jan.', 'Feb.', 'Mar.', 'Apr.', "Jun.", 'Jul.', 'Aug.', 'Sep', 'Oct.', 'Nov.', 'Dec.']
DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

module InterestingThings
  
  class TextResource
    attr_accessor :source_uri
    attr_accessor :plain_text
    attr_accessor :sentence_boundaries
    attr_accessor :categories
    attr_accessor :summary
  
    def initialize source_uri=''
      puts "++ entered TextResource constructor"
      @source_uri = source_uri
    end
    def cleanup_plain_text text
      def remove_extra_whitespace text
        text = text.gsub(/\s{2,}|\t|\n/,' ') # Peter's suggestion
        text
      end
      text.gsub!('>', '> ')
      if text.index('<') && text.index('>') # probably HTML
        text = HTML::FullSanitizer.new.sanitize(text)
      end
      remove_extra_whitespace(text)
    end
  
    def process_text_semantics! text
      cs = ClassifierAndSummarization.new
      cs.train([['wikipedia_text/computers.txt', "Computers"],
               ['wikipedia_text/economy.txt', "Economy"],
               ['wikipedia_text/health.txt', "Health"],
               ['wikipedia_text/software.txt', "Software"]])
      results = cs.classify_and_summarize_plain_text(@plain_text)
      @categories = results[0]
      @summary = results[1]
      @summary = @title + ". " + @summary if @title.length > 1
      @sentence_boundaries = get_sentence_boundaries(@plain_text)
      ee = EntityExtraction.new(@plain_text)
      @human_names = ee.human_names
      @place_names = ee.place_names
      st = SentimentOfText.new
      @sentiment_rating = st.get_sentiment(@plain_text)
    end
    def get_sentence_boundaries text
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
  end

  class PlainTextResource < TextResource
    def initialize source_uri=''
      puts "++ entered PlainTextResource constructor"
      super(source_uri)
      file = open(source_uri)
      @plain_text = cleanup_plain_text(file.read)
      process_text_semantics!(@plain_text)
    end
  end

  class HtmlXhtmlResource < TextResource
    def initialize source_uri=''
      puts "++ entered HtmlXhtmlResource constructor"
      super(source_uri)
      # parse HTML:
      doc = Nokogiri::HTML(open(source_uri))
      @plain_text = cleanup_plain_text(doc.inner_text)
      process_text_semantics!(@plain_text)
    end
  end

  class OpenDocumentResource < TextResource
    class OOXmlHandler
      include StreamListener
      attr_reader :plain_text
      attr_reader :headers
      def tag_start name, attrs
        #puts "+++ tag start: name: #{name}  attrs: #{attrs}"
        @last_name = name
      end
      def text s
        if @last_name.index('text:h')
          s = s.strip
          @headers << s if s.length > 0
        end
        if @last_name.index('text')
          s = s.strip
          if s.length > 0
            @plain_text << s
            @plain_text << "\n"
          end 
        end
      end
    end
    def initialize source_uri=''
      puts "++ entered OpenDocumentResource constructor"
      super(source_uri)
      # parse OpenDocument format:
      Zip::ZipFile.open(source_uri) {
        |zipFile|
        xml_h = OOXmlHandler.new
        Document.parse_stream((zipFile.read('content.xml')),
                              xml_h)
        @plain_text = cleanup_plain_text(xml_h.plain_text)
        @headers_1 = xml_h.headers
     }
     process_text_semantics!(@plain_text)
    end
  end

  ## NLP Utility classes:

  class Classifier
    def initialize
      @category_names = []
      @category_wc_hashes = []
      @noise_words = ['the', 'a', 'at', 'he', 'she', 'it']
    end
    def classify_text text
      word_stems = text.downcase.scan(/[a-z]+/)
      scores = Array.new(@category_names.length)
      @category_names.length.times {|i|
        scores[i] = score(@category_wc_hashes[i], word_stems)
      }
      best_index = scores.index(scores.max)
      best_hash = @category_wc_hashes[best_index]
      breaks = get_sentence_boundaries(text)
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
      breaks = get_sentence_boundaries(text)
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
    
    
    ## TBD: read database, get all documents with user assigned categories, use text to train:
    
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

  ## classifier using word count statistics:

  class ClassifierWordCountStatistics
    def initialize
      @category_names = []
      @category_wc_hashes = []
      @noise_words = ['the', 'a', 'at', 'he', 'she', 'it']
    end
    def classify_plain_text text
      word_stems = text.downcase.scan(/[a-z]+/)
      scores = Array.new(@category_names.length)
      @category_names.length.times {|i|
        scores[i] = score(@category_wc_hashes[i], word_stems)
      }
      [@category_names[scores.index(scores.max)]]
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

  ## calculate sentiment in text:

  class ClassifierWordCountStatistics
    def get_sentiment text
      word_stems = text.downcase.scan(/[a-z]+/)
      scores = Array.new(2)
      2.times {|i|
        scores[i] = score(@category_wc_hashes[i], word_stems)
      }
      scores[0] - scores[1]
    end
  end

  class SentimentOfText
    def initialize
      @classifier = ClassifierWordCountStatistics.new
      @classifier.train([['data/positive.txt', "Positive sentiment"],
                         ['data/negative.txt', "Negative sentiment"]])
    end
    def get_sentiment text
      @classifier.get_sentiment(text)
    end
  end

  ## sentence boundaries:

  HUMAN_NAME_PREFIXES_OR_ABREVIATIONS = ['Mr.', 'Mrs.', 'Ms.', 'Dr.', 'Sr.', 'Maj.', 'St.', 'Lt.', 'Sen.', 'Jan.', 'Feb.', 'Mar.', 'Apr.', "Jun.", 'Jul.', 'Aug.', 'Sep', 'Oct.', 'Nov.', 'Dec.']
  DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

  def get_sentence_boundaries text
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

  ## entity extraction:

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

  #words.each_with_index {|word, i|
  #  puts "#{word}\t#{word_flags[i].join(' ')}"
  #}

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

  
end

