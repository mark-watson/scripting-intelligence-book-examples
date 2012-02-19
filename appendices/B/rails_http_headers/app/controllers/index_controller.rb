require 'pp'

class IndexController < ApplicationController
  def index
    respond_to do |format|
      format.html { @request_type = request.format.to_s }
      format.n3   { render :text => "RDF N3 text" }
      format.rdf  { render :text => "RDF XML text" }
    end
  end
end
