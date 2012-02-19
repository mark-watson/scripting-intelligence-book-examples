# This is an abstract class. Concrete derived classes
# are RedlandBackend and SesameBackend

# this class provides some behavior for implementing search
# and lets the two derived classes to handle SPARQL queries
 
class SemanticBackend
  def query a_query
    @@back_end.query(a_query)
  end
  def SemanticBackend.set_back_end be
    @@back_end = be
  end
  def SemanticBackend.load_new_rdf_file file_path
    @@back_end.load_new_rdf_file(file_path)
  end
  def SemanticBackend.initialized?
    @@back_end != nil
  end
end

# Test to see if we are running under JRuby or CRuby:
begin
  include Java
  require 'sparql_endpoint_web_service/sesame_backend'
  SesameBackend.loadRepositories
  SemanticBackend.set_back_end(SesameBackend.new)
rescue
  require 'sparql_endpoint_web_service/redland_backend'
  RedlandBackend.loadRepositories
  SemanticBackend.set_back_end(RedlandBackend.new)
end

raise "Could not load an RDF backend" if !SemanticBackend.initialized?
