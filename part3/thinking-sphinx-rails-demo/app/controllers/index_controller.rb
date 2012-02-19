require 'pp'

class IndexController < ApplicationController
  def index
    pp params
    @results = []
    @query = params['search_text']
    if @query
      @results = NewsArticle.search(@query)
      pp @results
    else
      @query = ''
    end
  end
end
