require 'pp'
require 'cgi'

class SearchController < ApplicationController
  #auto_complete_for :name_link, :name, :limit => 25
  protect_from_forgery :only => [:create, :update, :destroy]
  def index
  end

  def auto_complete_for_name_link_name
    pp params
    if params['name_link'] && name = params['name_link']['name']
      results = ActiveRecord::Base.connection.execute("select name, url from name_links where name like '%#{name}%' limit 15")
      #pp results
      #results.each {|rr| pp "rr:", rr}
      html = "<ul>"
      results.each {|pname, plink| html << ("<li>#{pname}<br/>&nbsp;&nbsp;<a href=\"#{plink}\">#{CGI.unescape(plink)}</a></li>") if plink.length<81}
      html << "</ul>" 
      #puts html
      render :inline => html
    end
  end
end
