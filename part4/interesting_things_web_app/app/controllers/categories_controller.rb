require 'pp'

class CategoriesController < ApplicationController
  protect_from_forgery :only => [:create, :update, :delete]
  
  def index
    pp "^^^^^", params
    @doc_list = []
    if params['document_category'] && cname = params['document_category']['category_name']
       DocumentCategory.find(:all, :order => :likelihood,  :conditions => {:category_name => cname}).each {|dc|
         @doc_list << Document.find(dc.document_id)
       }
       pp @doc_list
    end
    @category_display_name = cname || ''
    session['search_text'] = @category_display_name # required when using a home controller fragment _results.erb
  end
  
  def auto_complete_for_document_category_category_name
    c_names = Document.get_all_category_names
    html = '<ul>'
    if params['document_category'] && cname = params['document_category']['category_name']
      c_names.each {|cn| html << "<li>#{cn}</li>" if cn.index(cname)}
    end
    html << '</ul>'
    render :inline => html
  end
end

