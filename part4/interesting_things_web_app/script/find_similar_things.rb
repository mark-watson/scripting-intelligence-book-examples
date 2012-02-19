#!/usr/bin/env ruby

MODE = 'development'

require 'pp'

$: << File.dirname(__FILE__) + '/../vendor/plugins/thinking-sphinx/lib'
$: << File.dirname(__FILE__) + '/../app/models/'

require 'thinking_sphinx' # only required so model files will load
require 'activerecord'
require 'document'
require 'similar_link'

database_config = YAML.load_file(File.dirname(__FILE__) + "/../config/database.yml")
database_name = database_config[MODE]['database']
database_adapter = database_config[MODE]['adapter']

puts "\n******* Starting script find_similar_things.rb *******\n"
puts "** Database adapter: #{database_adapter}"
puts "** Database name:    #{database_name}"

ActiveRecord::Base.establish_connection(:adapter  => database_adapter, :database => database_name)

doc_ids = Document.find(:all, :select=>'id').collect {|doc| doc.id}

doc_ids.each {|id_1|
  doc_1 = Document.find(id_1) 
  ss = doc_1.get_similar_document_ids
  doc_ids.each {|id_2|
    if id_1 != id_2
      links = SimilarLink.find(:first, :conditions => {:doc_id_1 => id_1, :doc_id_2 => id_2})
      if !links
        doc_2 = Document.find(id_2)
        similarity = doc_1.similarity_to(doc_2)
        puts "similarity: #{similarity} #{doc_1.original_source_uri} #{doc_2.original_source_uri}"
        if similarity > 0.1
          SimilarLink.new(:doc_id_1 => id_1, :doc_id_2 => id_2, :strength => similarity).save!
        end
      end
    end 
  }
}


