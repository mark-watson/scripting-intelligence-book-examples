$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'sinatra'
require 'json'

require File.dirname(__FILE__) + '/sparql_endpoint_web_service/semantic_backend.rb'

class SparqlEndpointWebService
  VERSION = '1.0.0'
end
