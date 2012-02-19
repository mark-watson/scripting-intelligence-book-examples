require 'pp'

class AdminController < ApplicationController
  def index
    @admin_status = ''
    @sphinx_start = nil
    @sphinx_stop = nil
    begin
      Document.search('hipporandonous')
      @sphinx_stop = true
    rescue
      @sphinx_start = true
    end
    pp params
    @admin_status = `rake thinking_sphinx:index` if params['command'] == 'sphinx_index'
    if params['command'] == 'sphinx_start'
      @admin_status = `rake thinking_sphinx:start`
      @sphinx_start = nil
      @sphinx_stop = true
    end
    if params['command'] == 'sphinx_stop'
      @admin_status = `rake thinking_sphinx:stop`
      @sphinx_start = true
      @sphinx_stop = nil
    end
    @admin_status = `script/find_similar_things.rb` if params['command'] == 'find_similar_stuff'
  end

end


