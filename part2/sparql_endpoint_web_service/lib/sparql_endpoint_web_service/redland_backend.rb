
puts 'Loading RedlandBackend...'

require 'rdf/redland'
require 'pp'

class RedlandBackend
 
  def RedlandBackend.loadRepositories
    if ENV['RDF_DATA']
      rdf_path = ENV['RDF_DATA']
    else
      rdf_path = 'rdf_data'
    end

    storage=Redland::TripleStore.new("hashes", "test", "new='yes',hash-type='bdb',dir='temp_data'")
    #storage=Redland::TripleStore.new("hashes", "test", "new='yes',hash-type='memory',dir='temp_data'")
    raise "Failed to create RDF storage" if !storage
    @@model=Redland::Model.new(storage)
    raise "Failed to create RDF model" if !@@model
    Dir.entries(rdf_path).each {|fname|
      if fname.index('nt')
        puts "* loading RDF repository: #{rdf_path + '/' + fname}"
        uri=Redland::Uri.new('file:' + rdf_path + '/' + fname)
        parser=Redland::Parser.new("ntriples", "", nil)
        raise "Failed to create RDF parser" if !parser
        stream=parser.parse_as_stream(uri, uri)
        while !stream.end?()
          statement=stream.current()
          @@model.add_statement(statement)
          stream.next()
        end
      end
    }
  end
  
  def load_new_rdf_file file_path
    begin
      if file_path.index('nt')
        puts "* loading RDF file into repository: #{file_path}"
        uri=Redland::Uri.new('file:' + file_path)
        parser=Redland::Parser.new("ntriples", "", nil)
        raise "Failed to create RDF parser" if !parser
        stream=parser.parse_as_stream(uri, uri)
        while !stream.end?
          statement=stream.current
          @@model.add_statement(statement)
          stream.next
        end
      end
    rescue
      puts "Error: #{$!}"
    end
  end
  
  def query sparql_query
    #puts "\nQuery: #{sparql_query}\n"
    ret = []
    q = Redland::Query.new(sparql_query)
    results=q.execute(@@model)
    while !results.finished?()
      temp = []
      for k in 0..results.bindings_count()-1
        s = results.binding_value(k).to_s.gsub('[','<').gsub(']','>')
        #s = '"' + s + '"' if !s.index('<')
        temp << s
      end
      ret << temp
      results.next()
    end
    ret
  end

end

