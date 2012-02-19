require 'rubygems'
require 'activerdf_agraph'

server = AllegroGraph::Server.new('http://localhost:8111/sesame')
repo = server.new_repository('test4')
repo.load_ntriples('data/foaf.nt')
ConnectionPool.add_data_source(:type => :agraph, :repository => repo)
repo.query(<<EOF)
SELECT ?s WHERE {
  ?s
  <http://www.w3.org/1999/02/22-rdf-syntax-ns#type>
  <http://www.w3.org/2000/01/rdf-schema#Class>
}
EOF
