require 'rubygems'
require 'sinatra'
require 'json'
require 'cgi'
require 'lib/sparql_endpoint_web_service'
require 'pp'

get '/*' do
  content_type 'text/json'
  # matches /sinatra and the like and sets params[:name]
  pp params
  if params['query']
    query = CGI.unescape(params['query'])
    puts "query =|#{query}|"
    #JSON.generate(dummy)
    ses = SemanticBackend.new
    response = ses.query(query)
    pp response
    j = JSON.generate(response)
    pp j
    return j.to_s
  end
end
