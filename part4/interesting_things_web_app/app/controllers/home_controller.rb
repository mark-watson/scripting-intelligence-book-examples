require 'pp'

class HomeController < ApplicationController
  protect_from_forgery :only => [:create, :update, :delete]
  
  def index
    @upload_status = ''
    @web_upload_status = ''
    @results = []
    @query = params['search_text']
    session['search_text'] = @query
    if @query
      @results = Document.search(@query) || [] 
      @results.delete(nil) # in case rows are deleted from table, and still in Sphinx index
    else
      @query = ''
    end
    pp "^^^^^ home index: @results = ", @results
  end

  def get_url
    
    status = Document.from_web_url(params[:web_url])
    if status
      @web_upload_status = "Web fetch OK"
    else
      @web_upload_status = "Web fetch failed"
    end

  end
  
  def upload
    Document.from_local_file(params[:uploaded_file].path, params[:uploaded_file].original_filename)
    @upload_status = "Upload OK"
  end
    
  def result_detail
    @doc = Document.find(params[:doc_id])
    @dcs = @doc.document_categories.collect {|dc| dc.category_name}
    @all_cats = Document.get_all_category_names
    render :partial => 'results'
  end

  def update_summary
    begin
      doc = params['doc']
      Document.update(doc['id'], :summary => doc['summary'])
      render :text => "Summary update OK"
    rescue
      render :text => "Error: #{$!}"
    end
  end
  
  def update_categories
    begin
      pp "\n\n\n\n^^^^^^^^^^^^^^^^^^^^^^ update_categories: params:"
      pp params
      doc = params['doc']
      cat_names = params.collect {|p|
         p[0] if !['authenticity_token', '_', 'commit', 'controller', 'action', 'doc'].include?(p[0])
       }
      cat_names.delete(nil)
      doc = Document.find(doc['id'].to_i)
      doc.document_categories.clear
      pp "^^^ cat_names:", cat_names
      cat_names.each {|cn| doc.category_assigned_by_user(cn)}
      doc.save!
      render :text => "Categories update OK"
    rescue
      puts "^^^^^^^^^Error: #{$!}"
      render :text => "Error: #{$!}"
    end
  end
    
end
