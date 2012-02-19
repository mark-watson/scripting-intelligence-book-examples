require 'rubygems'
require 'sinatra'
require 'json'
require 'cgi'
require 'lib/sparql_endpoint_web_service'
require 'pp'

# don't trust Redand or Sesame's concurency support: lock while writing to repositories:
$lock = false

get '/*' do
  content_type 'text/json'
  # matches /sinatra and the like and sets params[:name]
  #pp params
  if params['query']
    query = CGI.unescape(params['query'])
    #puts "query =|#{query}|"
    while $lock
      puts "RDF repository locked by writing thread, waiting..."
      sleep(0.1)
    end
    $lock = true
    ses = SemanticBackend.new
    response = ses.query(query)
    $lock = false
    #pp response
    j = JSON.generate(response)
    #pp j
    return j.to_s
  end
end

##      Manage loading new files:

# record files already in the repository:
$already_loaded = {}
Dir.glob('rdf_data/*.nt').each {|file| $already_loaded['rdf_data/' + file] = true}

# monitor the rdf_data directory, looking for newly added files:
work_thread = Thread.new {
  sleep(10) # wait 10 seconds for web portal to start
  file_path = ''
  loop do
    begin
      Dir.glob('rdf_data/*.nt').each {|file_path|
        if !$already_loaded[file_path]
          while $lock
            puts "RDF repository locked by reading thread, waiting..."
            sleep(0.1)
          end
          $lock = true
          # load file:
          begin
            sleep(1) # wait one second to make sure that the file is fully written and closed
            SemanticBackend.load_new_rdf_file(file_path)
            puts " * file #{file_path} has been loaded..."
          rescue
            puts "Error calling SemanticBackend.load_new_rdf_file(#{file_path}): #{$!}"
          end
          $lock = false
          $already_loaded[file_path] = true
        end
      }
    rescue
      puts "Error adding new file #{file_path} to RDF Reository: #{$!}"
    end
    sleep(10) # wait for 10 seconds before checking for new RDF files
  end
}
 
