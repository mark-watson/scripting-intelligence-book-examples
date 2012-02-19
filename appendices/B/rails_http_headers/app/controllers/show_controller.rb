require 'pp'

class ShowController < ApplicationController
  def index
    @news = News.find(request[:id])
    pp "@news:", @news
    respond_to do |format|
      puts "format: #{format}"
      puts  @news.to_rdf_xml
      format.html
      format.n3   { render :text => @news.to_rdf_n3 }
      format.rdf  { render :text => @news.to_rdf_xml }
    end
  end

end
