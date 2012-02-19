require 'pp'

class News < ActiveRecord::Base
  set_table_name :news
  def to_rdf_n3
    pp self
    "@prefix kb: <http://knowledgebooks.com/test#> .\n\n" + 
    "<http://localhost:3000/show/index/#{self.id}> kb:title \"#{self.title}\";\n" +
    "                                     kb:contents \"#{self.contents}\".\n"
  end
  def to_rdf_xml
    "<?xml version=\"1.0\" encoding=\"utf-8\"?>
    <rdf:RDF xmlns:kb=\"http://knowledgebooks.com/test#\"
             xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">
      <rdf:Description rdf:about=\"http://localhost:3000/show/index/#{self.id}\">
        <kb:title>#{self.title}</kb:title>
      </rdf:Description>
      <rdf:Description rdf:about=\"http://localhost:3000/show/index/#{self.id}\">
        <kb:contents>#{self.contents}</kb:contents>
      </rdf:Description>
    </rdf:RDF>"
  end
end
