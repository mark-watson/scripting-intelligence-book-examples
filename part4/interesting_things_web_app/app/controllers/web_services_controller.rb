class WebServicesController < ApplicationController
  def category_names
    render :json => { :category_names => Document.get_all_category_names }
  end
  
  def interesting_thing_by_id
    hash = {}
    id = params[:id]
    if id && doc = Document.find(id.to_i)
      hash = {:id => doc.id,
              :original_source_uri => doc.original_source_uri,
              :uri => doc.uri,
              :summary => doc.summary,
              :plain_text => doc.plain_text,
              :categories => doc.document_categories.collect {|dc| dc.category_name},
              :similar_things => doc.get_similar_document_ids
             }
    end
    render :json => hash
  end
  
  def search
    hash = {}
    if params[:q] && results = Document.search(params[:q])
      hash = {:doc_ids => results.collect {|doc| doc.id}}
    end
    render :json => hash
  end
end
