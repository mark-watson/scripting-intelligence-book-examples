require 'pp'
require 'rubygems'
require 'net/http'
require 'tempfile'
require 'nokogiri'
require 'simple-rss'
require 'atom'
require 'open-uri'
require 'zip/zipfilesystem'
require 'rexml/document'
require 'rexml/streamlistener'
include REXML

class TextResource
  attr_accessor :source_uri
  attr_accessor :plain_text
  attr_accessor :title
  attr_accessor :headings_1
  attr_accessor :headings_2
  attr_accessor :headings_3
  attr_accessor :sentence_boundaries
  attr_accessor :categories
  attr_accessor :place_names
  attr_accessor :human_names
  attr_accessor :product_names
  attr_accessor :summary
  attr_accessor :sentiment_rating # [-1..+1]  positive number implies positive sentiment
  
  def initialize source_uri=''
    puts "++ entered TextResource constructor"
    @source_uri = source_uri
    @title = ''
    @headings_1 = []
    @headings_2 = []
    @headings_3 = []
  end
  def cleanup_plain_text text
    def remove_extra_whitespace text
      text = text.gsub(/\s{2,}|\t|\n/,' ')
      text
    end
    text.gsub!('>', '> ')
    if text.index('<') && text.index('>') # probably HTML
      text = HTML::FullSanitizer.new.sanitize(text)
    end
    remove_extra_whitespace(text)
  end
  def process_text_semantics! text # just a placeholder until chapter 3
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

class BinaryPlainTextResource < TextResource
  def initialize source_uri=''
    puts "++ entered BinaryPlainTextResource constructor"
    super(source_uri)
    file = open(source_uri)
    text = file.read
    text = remove_noise_characters(text)
    text = remove_words_not_in_spelling_dictionary(text)
    @plain_text = cleanup_plain_text(text)
    process_text_semantics!(@plain_text)
  end
  def remove_noise_characters text
    text # stub: will be implemented in chapter 2
  end
  def remove_words_not_in_spelling_dictionary text
    text # stub: will be implemented in chapter 2
  end
end

class HtmlXhtmlResource < TextResource
  def initialize source_uri=''
    puts "++ entered HtmlXhtmlResource constructor"
    super(source_uri)
    # parse HTML:
    doc = Nokogiri::HTML(open(source_uri))
    @plain_text = cleanup_plain_text(doc.inner_text)
    @headings_1 = doc.xpath('//h1').collect {|h| h.inner_text.strip}
    @headings_2 = doc.xpath('//h2').collect {|h| h.inner_text.strip}
    @headings_3 = doc.xpath('//h3').collect {|h| h.inner_text.strip}
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

class RssResource < TextResource
  def initialize
    super('')
  end
  def self.get_entries source_uri=''
    entries = []
    rss = SimpleRSS.parse(open(source_uri))
    items = rss.items
    items.each {|item|
      content = item[:content_encode] || item[:description] || item[:title] || ''
      entry = RssResource.new
      entry.plain_text = entry.cleanup_plain_text(content)
      entry.process_text_semantics!(entry.plain_text)
      entry.source_uri = item[:link] || ''
      entry.title = item[:title] || ''
      entries << entry
    }
    entries
  end
end

class AtomResource < TextResource
  def initialize 
    super('')
  end
  def self.get_entries source_uri=''
    ret = []
    str = Net::HTTP::get(URI::parse(source_uri))
    atom = Atom::Feed.new(str)
    entries = atom.entries
    entries.each {|entry|
      temp = AtomResource.new
      content = entry.content.value || ''
      temp.plain_text = temp.cleanup_plain_text(content)
      temp.process_text_semantics!(temp.plain_text)
      temp.source_uri = entry.links[0].href || ''
      temp.title = entry.title || ''
      ret << temp
    }
    ret
  end
end

require 'pp'
#tr = TextResource.new("/Users/markw/Documents/Reading and Papers/from_web/n-gram-based-text.pdf")
#pp tr
#tr.title = "test title"
#puts tr.title

#tr = TextResource.new("http://www.markwatson.com/music/Mark_Watson_Boogie1.mp3")
#pp tr

#tr = TextResource.new("http://www.markwatson.com/opencontent/FishFarm.pdf")
#pp tr

#tr = HtmlXhtmlResource.new("http://www.markwatson.com")
#pp tr

#tr = OpenDocumentResource.new('/Users/markw/Documents/WORK/Scripting Intelligence - Web 3.0 Information Gathering and Processing/chapters/chapter01.odt')
#pp tr

#tr = RssResource.get_entries('http://feeds.boingboing.net/boingboing/iBag')
#pp tr

tr = AtomResource.get_entries('http://oddthesis.org/posts.atom')
pp tr
