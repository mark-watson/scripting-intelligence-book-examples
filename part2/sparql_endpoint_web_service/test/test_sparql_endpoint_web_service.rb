require 'test/unit'

require 'sparql_endpoint_web_service'

require 'pp'

class TestSparqlEndpointWebService < Test::Unit::TestCase

  def setup
  end
  
  def test_truth
    assert true
    #assert_equal("religion_buddhism", categories[0][0])
    ses = SemanticBackend.new
    pp ses.query(" SELECT ?s ?o WHERE { ?s <http:://knowledgebooks.com/ontology/#summary> ?o } ")
  end
end
