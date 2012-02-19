require 'pp'

class IndexController < ApplicationController
  def index
    pp params
    @results = []
    @query = params['search_text']
    if @query
      search = Ultrasphinx::Search.new(:query => @query)
      search.run
      @results = search.results
      pp @results
    else
      @query = ''
    end
  end
end
