require 'rubygems' # only needed for Ruby 1.8.6
require 'open-uri'

def get_article_as_1_line uri
  ret = ""
  begin
    open(uri) { |inp|
      ret << inp.base_uri.to_s << "\t "
      inp.each do |line|
        ret << line.gsub(/<\/?[^>]*>/, " ")
        ret << " "
      end    
    }
  rescue
    puts "Error: #{$!}"
  end
  ret.gsub("\n", "").gsub('\t',' ').gsub('         ',' ').gsub('      ',' ').gsub('    ', ' ').gsub('  ', ' ')
end

def get_random_article
  get_article_as_1_line "http://en.wikipedia.org/wiki/Special:Random"
end

5.times {|iter|
  File.open("wikipedia_data_#{iter+1}.txt", 'w') do |f|  
    5000.times {|i|
      f.puts get_random_article
      sleep(15)
    }
  end
}
