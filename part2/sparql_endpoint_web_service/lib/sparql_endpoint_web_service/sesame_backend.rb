puts "Loading SesameBackend..."

puts Dir.entries("lib")
require 'lib/rsesame.jar'
include_class "SesameWrapper"

require 'pp'

# Use duck typing: define a class implementing the method "triple" :
class SesameCallback
  attr_reader :results
  def initialize
    @results = []
  end
  def triple result_list # called for each SPARQL query result
    pp result_list
    ret = []
    result_list.each {|result|
      if result.index('http:') || result.index('https:')
         ret << "<" + result + ">"
      else
         ret << result
      end
    }
    @results << ret
  end
end

class SesameBackend
  def SesameBackend.loadRepositories
    if ENV['RDF_DATA']
      rdf_path = ENV['RDF_DATA']
    else
      rdf_path = 'rdf_data'
    end
    @@tsm = SesameWrapper.new
    Dir.entries(rdf_path).each {|fname|
      if fname.index('.nt')
        begin
          puts "* loading RDF repository into Sesame: #{rdf_path + '/' + fname}"
          #pp @@tsm
          #pp @@tsm.public_methods.sort
          @@tsm.load_ntriples(rdf_path + '/' + fname)
        rescue
          puts "Error: #{$!}"
        end
      end
    }
  end
  def load_new_rdf_file file_path
    begin
      puts "* loading RDF repository file into Sesame: #{file_path}"
      @@tsm.load_ntriples(file_path)
    rescue
      puts "Error: #{$!}"
    end
  end
  def query sparql_query
    callback = SesameCallback.new
    @@tsm.query(sparql_query, callback)
    callback.results
  end
end
