require 'pp'
require 'stemmer'
require 'fileutils'
require 'open-uri'

HUMAN_NAME_PREFIXES_OR_ABREVIATIONS = ['Mr.', 'Mrs.', 'Ms.', 'Dr.', 'Sr.', 'Maj.', 'St.', 'Lt.', 'Sen.', 'Jan.', 'Feb.', 'Mar.', 'Apr.', "Jun.", 'Jul.', 'Aug.', 'Sep', 'Oct.', 'Nov.', 'Dec.']
DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

class Document < ActiveRecord::Base
  has_many :document_categories, :dependent => :destroy
  has_many :similar_links, :dependent => :destroy
  attr_accessor :calculated_summary
  attr_accessor :calculated_categories
  @@cat_names = nil
  @@noise_stems = nil
  
  define_index do
    indexes [:plain_text]
  end

  def self.from_local_file file_path, original_source_uri
    index = original_source_uri.rindex(".")
    file_extension = original_source_uri[index..-1]
    permanent_file_path = "db/document_repository/d#{Date.new.to_s}-#{rand(100000).to_s}#{file_extension}"
    plain_text = ''
    if file_extension == ".txt"
      FileUtils.cp(file_path, permanent_file_path)
      plain_text = File.new(permanent_file_path).read
    elsif file_extension == ".pdf"
      `pdftotext #{file_path} #{permanent_file_path}`
      plain_text = File.open(permanent_file_path, 'r').read
    elsif file_extension == ".doc"
      plain_text = `antiword #{file_path}`
      File.open(permanent_file_path, 'w') {|out| out.puts(plain_text)}
    end
    doc = Document.new(:uri => permanent_file_path, :plain_text => plain_text, :original_source_uri => original_source_uri)
    doc.semantic_processing
    doc.summary = doc.calculated_summary
    doc.save! # need to set doc's id before the next code block:
    pp "** doc.calculated_categories:", doc.calculated_categories
    score = 0.5
    doc.calculated_categories.each {|category|
      doc.category_assigned_by_nlp(category, score) if score > 0.1
      score *= 0.5
    }
  end
  
  def self.from_web_url a_url
    puts "\n** Document.from_web_url:  #{a_url}"
    begin
      plain_text = open(a_url).read.gsub(/<\/?[^>]*>/, " ").gsub('  ', ' ').gsub('  ', ' ')
      puts "\n** #{plain_text[0..40]}"
      return false if plain_text.index("File Not Found")
      return false if plain_text.index("404 Not Found")
      return false if plain_text.index("Error: getaddrinfo")
      file_extension = '.html'
      permanent_file_path = "db/document_repository/d#{Date.new.to_s}-#{rand(100000).to_s}#{file_extension}"
      doc = Document.new(:uri => permanent_file_path, :plain_text => plain_text, :original_source_uri => a_url)
      doc.semantic_processing
      doc.summary = doc.calculated_summary
      doc.save! # need to set doc's id before the next code block:
      pp "** doc.calculated_categories:", doc.calculated_categories
      score = 0.5
      doc.calculated_categories.each {|category|
        doc.category_assigned_by_nlp(category, score) if score > 0.1
        score *= 0.5
      }
    rescue
      puts "\n** Document.from_web_url:  #{a_url}  Error: #{$!}"
      return false
    end
    true # OK
  end
  
  def Document.get_all_category_names
    return @@cat_names if @@cat_names
    result = ActiveRecord::Base.connection.execute("select distinct category_name from category_words order by category_name asc")
    @@cat_names = []
    result.each {|x| @@cat_names << x[0]} # MySQL::Result class has no collect method
    result.free 
    @@cat_names
  end
  
  def Document.get_noise_word_stems
    return @@noise_stems if @@noise_stems
    @@noise_stems = []
    f = File.open('db/stop_words.txt')
    f.read.split("\n").each {|line|
      @@noise_stems << line.strip.stem
    }
    f.close
    @@noise_stems
  end
        
  def semantic_processing
    # debug:
    #CategoryWord.find(:all).each {|cw| pp "** category word from database:", cw }
    
    category_names = Document.get_all_category_names
    breaks = get_sentence_boundaries(plain_text)
    word_stems = plain_text.downcase.scan(/[a-z]+/).collect {|word| word.stem}
    scores = Array.new(category_names.length)
    category_names.length.times {|i| scores[i] = 0}
    word_stems.each {|stem|
      puts "** word stem: #{stem}"
      CategoryWord.find(:all, :conditions => {:word_name => stem}).each {|cw|
        index = category_names.index(cw.category_name)
        scores[index] += cw.importance
      }
    }
    pp "** scores:", scores
    slist = []
    category_names.length.times {|i| slist << [scores[i], category_names[i]] if scores[i] > 0}
    slist = slist.sort.reverse
    @calculated_categories = slist[0..category_names.length/3+1].collect {|score, cat_name| cat_name}

    best_category = @calculated_categories[0]    
    sentence_scores = Array.new(breaks.length)
    breaks.length.times {|i| sentence_scores[i] = 0}
    breaks.each_with_index {|sentence_break, i|
      tokens = plain_text[sentence_break[0]..sentence_break[1]].downcase.scan(/[a-z]+/).collect {|tt| tt.stem}
      tokens.each {|token|
        CategoryWord.find(:all, :conditions => {:word_name => token, :category_name => best_category}).each {|cw|
          sentence_scores[i] += cw.importance
        }
      }
      sentence_scores[i] *= 100.0 / (1 + tokens.length)
    }
    
    pp "sentence_scores:", sentence_scores
    
    score_cutoff = 0.8 * sentence_scores.max
    summary = ''
    sentence_scores.length.times {|i|
      if sentence_scores[i] >= score_cutoff
        summary << plain_text[breaks[i][0]..breaks[i][1]] << ' '
      end
    }
    @calculated_summary = summary.strip
  end
  
  def category_assigned_by_nlp category, likelihood
    category_assigned_helper(category, false, likelihood)
  end
  def category_assigned_by_user category
    category_assigned_helper(category, true, 1.0)
  end
  
  def similarity_to another_document
    noise = Document.get_noise_word_stems
    text_1 = ((plain_text.downcase.scan(/[a-z]+/).collect {|word| word.stem}) - noise).uniq
    text_2 = ((another_document.plain_text.downcase.scan(/[a-z]+/).collect {|word| word.stem}) - noise).uniq
    f1 = (text_1 & text_2).length.to_f
    f2 = text_1.length.to_f
    f3 = text_2.length.to_f
    (f1 * f1) / (f2 * f3)
  end
  
  def get_similar_document_ids
    SimilarLink.find(:all, :order => :strength, :conditions => {:doc_id_1 => id}).collect {|x| [x.doc_id_2, x.strength]}
  end
  
  private  # PRIVATE:
  def category_assigned_helper category, by_user, likelihood
    results = DocumentCategory.find(:first, :conditions => {:document_id => id, :category_name => category})
    pp "Document results: ", results
    if !results
      DocumentCategory.create(:document_id => id, :category_name => category, :set_by_user => by_user, :likelihood => likelihood)
    end
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
  