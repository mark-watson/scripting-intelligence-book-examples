require 'activerdf_agraph'
server = AllegroGraph::Server.new('http://localhost:8111/sesame')
repo = server.new_repository('sec2')
repo.load_ntriples('/Users/markw/Documents/WORK/RDFdata/RdfAbout_SEC_data/sec.nt')
ConnectionPool.add_data_source(:type => :agraph, :repository => repo)
repo.query(<<EOF)
REFIX foaf:  <http://xmlns.com/foaf/0.1/>
PREFIX sec: <http://www.rdfabout.com/rdf/schema/ussec/>
PREFIX seccik: <http://www.rdfabout.com/rdf/usgov/sec/id/>
SELECT DISTINCT ?name WHERE {
    [foaf:name ?name]
        sec:hasRelation [ sec:corporation [foaf:name "APPLE INC"] ];
        sec:hasRelation [ sec:corporation [foaf:name "Google Inc."] ].
}
EOF
