require 'rubygems'
#require 'lib/jruby-rack' # only for jruby
require 'sinatra'
require 'json'
require 'cgi'
require 'ftools'
require 'lib/sparql_endpoint_web_service'
require 'graphviz'
# License: GPL version 2 or later (because graphviz gem is GPL)
require 'pp'


get '/*' do
  #content_type 'text/json'
  
  pp params
  if params['query']
    query = CGI.unescape(params['query'])
    concise = params.key?('concise')
    if params.key?('dot')
      content_type 'text/dot'
      file_type = 'dot'
    else
      content_type 'image/png'
      file_type = 'png'
    end
    puts "query =|#{query}| concise=#{concise} file_type=#{file_type}"
    #JSON.generate(dummy)
    ses = SemanticBackend.new
    response = ses.query(query)
    pp response
    write_graph_file(response, concise, file_type)
    data = File.open("temp_data/gviz_#{$counter}.#{file_type}").read
    #File.delete("temp_data/gviz_#{$counter}.#{file_type}")
    data
  end
end

# delete all temp_data/gviz_*.png files:

# TBD

$counter = rand(10000) # gets reset for every request

# return a path to a temporary 
def write_graph_file response, concise_names=false, file_type='png'
  g = GraphViz::new( "G", "output" => file_type )
  g["rankdir"] = "LR"
  g.node["shape"] = "ellipse"
  g.edge["arrowhead"] = "normal"
  response.each {|triple|
    if triple.length == 3
      if concise_names
        3.times {|i| triple[i] = concise_name_for(triple[i]); puts triple[i]}
      end
      triple[2] = triple[2].gsub(' ', '_')
      g.add_node(triple[0])
      g.add_node(triple[2])
      g.add_edge( triple[0], triple[2], "arrowhead" => triple[2], :label => triple[1] )
    end
  }
  fpath = "temp_data/gviz_#{$counter}.#{file_type}"
  g.output( :file => fpath )
  puts "Output is in:   #{fpath}  counter: #{$counter}"
end

r = [["s1", "p1", "o1"], ["s2", "p2", "o2"], ["s1", "p3", "o3"], ["s1", "p4", "o4"]]
#write_graph_file r

def concise_name_for str
  if str[0..4] == "<http" && (index = str.gsub('/>','  ').rindex("/"))
    str[index+1..-2].gsub('#','').gsub('/',' ').strip
  else
    str
  end
end
