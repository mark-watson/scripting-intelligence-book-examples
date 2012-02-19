Part 3 Examples
===============


Chapter 8
---------

== ActiveRecord Tutorial:

Make sure that you create a MySQL database named "test":

/src/part3/activerecord# mysql 
mysql> create database test;
Query OK, 1 row affected (0.00 sec)
mysql> quit


Change directory to src/part3/activerecord
and initialize the three tables in database "test".

~/src/part3/activerecord# ruby ar_setup_example.rb 
-- create_table(:news_articles, {:force=>true})
   -> 0.0474s
-- create_table(:people, {:force=>true})
   -> 0.0062s
-- create_table(:places, {:force=>true})
   -> 0.0015s

After setting up the tables, then you can run the examples in the src/part3/activerecord directory:

~/src/part3/activerecord# ruby ar_classes_from_database_metadata.rb
[#<NewsArticle id: 1, url: "http://test.com/bigwave", title: "Tidal Wave Misses Hawaii", summary: "Tidal wave missed Hawaii by 500 miles", contents: "A large tidal wave travelled across the pacific, mi...">]

~/src/part3/activerecord# ruby ar_transactions_demo.rb
#<NewsArticle id: 1, url: "http://test.com/bigwave", title: "Tidal Wave Misses Hawaii", summary: "Tidal wave missed Hawaii by 500 miles", contents: "A large tidal wave travelled across the pacific, mi...">
#<Person id: 1, name: "Mark", news_article_id: 1>
#<Place id: 1, name: "Sedona Arizona", news_article_id: 1>

~/src/part3/activerecord# ruby ar_callback_demo.rb 
Create a new in-memory place:
Save the new in-memory place to the database:
monitor_before_place_save
monitor_before_place_creation
monitor_after_place_creation
monitor_after_place_save
Destroy the object and remove from database:
monitor_before_place_destroy
monitor_after_place_destroy

~/src/part3/activerecord# ruby ar_observer_demo.rb
Create a new in-memory place:
Save the new in-memory place to the database:
** Before saving #<Place:0xb7931ba8>
** After saving #<Place:0xb7931ba8>
Destroy the place object and remove from database:
Create a new in-memory person:
Save the new in-memory person to the database:
** Before saving #<Person:0xb78e71fc>
** After saving #<Person:0xb78e71fc>
Destroy the person object and remove from database:

~/src/part3/activerecord# ruby ar_execute_sql_demo.rb 
["id", "name", "news_article_id"]
["1", "Sedona, Arizona", "1"]
["name", "news_article_id"]
["Sedona, Arizona", "1"]

~/src/part3/activerecord# ruby ar_metadata_demo.rb 
"places"
["id", "name", "news_article_id"]
1


== Doing ORM with DataMapper:

Make sure that you have the required gems installed:

gem install do_sqlite3 do_postgres do_mysql dm-core dm-observer

Change directory to:  src/part3/datamapper

There is only one sample program in this section that contains all of the code snippets used in the text:

~/src/part3/datamapper# ruby dm_setup_example.rb 
[#<NewsArticle id=1 url="http://test.com/bigwave" title="Tidal Wave Misses Hawaii" summary="Tidal wave missed Hawaii by 500 miles" contents=<not loaded>>]
A large tidal wave travelled across the pacific, missing Hawaii by 500 miles
[#<NewsArticle id=1 url="http://test.com/bigwave" title="Tidal Wave Misses Hawaii" summary="Tidal wave missed Hawaii by 500 miles" contents="A large tidal wave travelled across the pacific, missing Hawaii by 500 miles">]
Object equality test: true
#<NewsArticle
 title = "Tidal Wave Misses Hawaii",
 summary = "Tidal wave missed Hawaii by 500 miles",
 contents = "A large tidal wave travelled across the pacific, missing Hawaii by 500 miles",
 url = "http://test.com/bigwave123",
 id = 1>
#<NewsArticle
 title = "100 pound goldfish caught",
 summary = "A 100 pound goldfish was caught by Mary Smith",
 contents = "A 100 pound goldfish was caught by Mary Smith using a bamboo fishing pole while fishing with her husband Bob",
 url = "http://test.com/bigfish",
 id = 2>
[#<NewsArticle id=1 url="http://test.com/bigwave123" title="Tidal Wave Misses Hawaii" summary="Tidal wave missed Hawaii by 500 miles" contents=<not loaded>>, #<NewsArticle id=2 url="http://test.com/bigfish" title="100 pound goldfish caught" summary="A 100 pound goldfish was caught by Mary Smith" contents=<not loaded>>]
* * * Person callback: save  #<Person:0xb783dbe8>
** PersonObserver: before save  #<Person:0xb783dbe8>
* * * Person callback: create  #<Person:0xb783dbe8>
** PersonObserver: after create #<Person:0xb783dbe8>
#<Person news_article_id = nil, name = "Mary Smith", id = 1>
#<Person news_article_id = nil, name = "Mary Smith", id = 1>
* * * Person callback: save  #<Person:0xb783dbe8>
** PersonObserver: before save  #<Person:0xb783dbe8>
[#<Person id=1 name="Mary Smith" news_article_id=2>]
#<NewsArticle
 title = "100 pound goldfish caught",
 summary = "A 100 pound goldfish was caught by Mary Smith",
 contents = "A 100 pound goldfish was caught by Mary Smith using a bamboo fishing pole while fishing with her husband Bob",
 url = "http://test.com/bigfish",
 id = 2>

* * * Person callback: save  #<Person:0xb783dbe8>
** PersonObserver: before save  #<Person:0xb783dbe8>
Mary 1
Sat, 06 Jun 2009 14:58:10 GMT ~ debug ~ default: begin
Inside a Person class transaction #<DataMapper::Transaction:0xb7829404>
* * * Person callback: save  #<Person:0xb783dbe8>
** PersonObserver: before save  #<Person:0xb783dbe8>
Mary, Mary
Sat, 06 Jun 2009 14:58:10 GMT ~ debug ~ default: rollback
Mary, Mary
* * * Person callback: save  #<Person:0xb783dbe8>
** PersonObserver: before save  #<Person:0xb783dbe8>
* * * Person callback: save  #<Person:0xb783dbe8>
** PersonObserver: before save  #<Person:0xb783dbe8>
before transaction test with no fail: Mary 2
Sat, 06 Jun 2009 14:58:10 GMT ~ debug ~ default: begin
Sat, 06 Jun 2009 14:58:10 GMT ~ debug ~ default: prepare
Sat, 06 Jun 2009 14:58:10 GMT ~ debug ~ default: commit
after transaction test with no fail: Mary 2, Ruby master
* * * Person callback: save  #<Person:0xb783dbe8>
** PersonObserver: before save  #<Person:0xb783dbe8>
before transaction test with fail: Mary 2
Sat, 06 Jun 2009 14:58:10 GMT ~ debug ~ default: begin
Sat, 06 Jun 2009 14:58:10 GMT ~ debug ~ default: rollback
after transaction test with fail: Mary 2, Ruby master
root@domU-12-31-39-03-02-57:~/src/part3/datamapper# 


Chapter 9
---------

== Using JRuby and Lucene: Note, that I need to require rubygems before jruby/lucene:

# jirb
irb(main):001:0> require 'rubygems'
=> true
irb(main):002:0> require 'jruby/lucene'
=> true
irb(main):003:0> lucene = Lucene.new('./temp_data')
=> #<Lucene:0x24c672 @index_path="./temp_data">
irb(main):004:0> lucene.add_documents([[1,"The dog ran quickly"], 
irb(main):005:2*                                              [2,'The cat slept in the sunshine']])
=> nil
irb(main):006:0> results = lucene.search('dog')
=> [[0.5, 1, "The dog ran quickly"]]
irb(main):008:0>

Assuming that you have JRuby and the jruby/lucene set up correctly so this interactive
example works for you, then try running the test scripts, as in the book text.


== Doing Spatial Search Using Geohash:

Install the geohash gem:  gem install davetroy-geohash
(if this fails, first add github: gem sources -a http://gems.github.com)

Then create the database tables:

mysql test
mysql> create table locations (id int, name varchar(30), geohash char(5), 
    ->                                    lat float, lon float);
Query OK, 0 rows affected (0.01 sec)

mysql> create index geohash_index ON locations (geohash, lat, lon);
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

Now create 50,000 rows of test dat and run the benchmark:

$ ruby create_data.rb 
$ ruby spacial-search-benchmark.rb 
  0.070000   0.000000   0.070000 (  6.520477)
  0.140000   0.010000   0.150000 (  0.581348)

Note: you may want to drop these tables after experimeting with the code.



== Using Solr Web Services:

I assume that you have setup Tomcat and Solr as per the instructions in Chapter 9.
If you are using my AMI (see Appendix A), then Tomcat and Solr are already
configured for you.

You need to install the Solr gem:  gem install solr-ruby

To run the client example:

cd src/part3/solr
ruby solr_test.rb 
{"popularity"=>0,
 "timestamp"=>"2009-06-06T17:23:10.263Z",
 "id"=>"2",
 "sku"=>"2",
 "score"=>0.2972674}
{"popularity"=>0,
 "timestamp"=>"2009-06-06T17:23:09.991Z",
 "id"=>"1",
 "sku"=>"1",
 "score"=>0.26010898}


== Using Nutch with Ruby Clients:

You need to install the reatclient gem if you have not previously done so: gem install rest-client

I assume that you have setup Tomcat and Nutch as per the instructions in Chapter 9.
If you are using my AMI (see Appendix A), then Tomcat and Nutch are already
configured for you.

Remember: as mentioned in the text, you must start Tomcat from the "nutch" sub-directory
and not from the top level Tomcat directory:

cd Tomcat
cd nutch/
../bin/catalina.sh run

To run the test client:  cd src/part3/nutch, then: ruby test_client.rb



== Using Sphinx with the Thinking Sphinx Rails Plugin:

You need to have Rails installed as well as Sphinx and the Thinking Sphinx plugin
(follow the directions in Chapter 9).

Change directory to src/part3/thinking-sphinx-rails-demo

Make sure that you have the correct version of rails installed: gem install -v=2.2.2 rails

Assuming that you have created the exmaple database in Chapter 8 (or are using my
AMI where everyhting is set up for you), then create an index:

rake thinking_sphinx:index 

Start the Sphinx serivce:

rake thinking_sphinx:start

And now start Rails:   script/server



== Using PostgreSQL Full-Text Search:

You need to create the database and table schema (unless you are using
my AMI, in which case this is already set up for you):

~/src/part3/postgresql-search $ createdb search_test -U postgres
~/src/part3/postgresql-search $ psql search_test -U postgres
search_test=# create table articles (id integer, title varchar( 30), 
search_test(# contents varchar(250));
search_test=# create table articles (id integer, title varchar( 30), contents varchar(250));
CREATE TABLE
search_test=# create index articles_contents_idx on articles using gin(to_tsvector('english', contents));
CREATE INDEX
search_test=# insert into articles values (1, 'Fishing Season Open', 'Last Saturday was the opening of Fishing season');
INSERT 0 1
search_test=# insert into articles values (2, 'Tennis Open Cancelled', 'The tennis open last weekend was cancelled due to rain');
INSERT 0 1

Here is a sample search query:

search_test=# select id, title from articles where to_tsvector(contents) @@ to_tsquery('open');
 id |         title         
----+-----------------------
  1 | Fishing Season Open
  2 | Tennis Open Cancelled
(2 rows)

Then you can run the client examples; for example:

~/src/part3/postgresql-search $ ruby postgresql-activerecord-simple.rb 
[["1",
  "Fishing Season Open",
  "Last Saturday was the opening of Fishing season"]]

~/src/part3/postgresql-search# ruby postgresql-activerecord.rb 
select * from articles where to_tsvector(title || contents) @@ to_tsquery('fish')
[["1",
  "Fishing Season Open",
  "Last Saturday was the opening of Fishing season"]]
select * from articles where to_tsvector(title || contents) @@ to_tsquery('watson')
[]



== Using MySQL Full-Text Search:

As per the book text, we need a MySQL table with a MYISAM back end:

$ mysql test
mysql> show tables;
+----------------+
| Tables_in_test |
+----------------+
| news_articles  | 
| people         | 
| places         | 
+----------------+
3 rows in set (0.00 sec)

mysql> create table news (id int, title varchar(30), contents varchar(200)) engine = MYISAM;
Query OK, 0 rows affected (0.01 sec)

The three old tables were created in earlier book examples.

Now, I add 3 test rows, and create a fulltext index:

mysql> insert into news values (1, 'Home Farming News', 'Both government officials and organic food activists agree that promoting home and community gardens is a first line of defense during national emergencies');
Query OK, 1 row affected (0.00 sec)

mysql> insert into news values (2, 'Families using less and enjoying themselves more', 'Recent studies have shown that families who work together to grow food, cook together, and maintain their own homes are 215% happier than families stuck in a "consumption rut".');
Query OK, 1 row affected, 1 warning (0.00 sec)

mysql> insert into news values (3, 'Benefits of Organic Food', 'There is now more evidence that families who eat mostly organic food may have fewer long term health problems.'); 
Query OK, 1 row affected (0.00 sec)

mysql> create fulltext index news_index on news (contents);
Query OK, 3 rows affected (0.01 sec)
Records: 3  Duplicates: 0  Warnings: 0

Here are some of the sample queries from the book text (refer to text for search syntax):

mysql> select title from news where match (contents) against ('+grow -food' in boolean mode);
Empty set (0.00 sec)

mysql> select title from news where match (contents) against ('+organic' in boolean mode);
+--------------------------+
| title                    |
+--------------------------+
| Home Farming News        | 
| Benefits of Organic Food | 
+--------------------------+
2 rows in set (0.00 sec)

Here are the two test clients:

~/src/part3/mysql-search# ruby mysql-activerecord-simple.rb 
[["1",
  "Home Farming News",
  "Both government officials and organic food activists agree that promoting home and community gardens is a first line of defense during national emergencies"],
 ["3",
  "Benefits of Organic Food",
  "There is now more evidence that families who eat mostly organic food may have fewer long term health problems."]]
root@domU-12-31-39-03-02-57:~/src/part3/mysql-search# ruby mysql-activerecord.rb        
[["1",
  "Home Farming News",
  "Both government officials and organic food activists agree that promoting home and community gardens is a first line of defense during national emergencies"],
 ["3",
  "Benefits of Organic Food",
  "There is now more evidence that families who eat mostly organic food may have fewer long term health problems."]]
[["1",
  "Home Farming News",
  "Both government officials and organic food activists agree that promoting home and community gardens is a first line of defense during national emergencies"],
 ["3",
  "Benefits of Organic Food",
  "There is now more evidence that families who eat mostly organic food may have fewer long term health problems."]]



Chapter 10
----------

Note: install the scrubyt gem from github, and not the released gem:

gem sources -a http://gems.github.com
sudo gem install scrubber-scrubyt

If you want to try the GraphViz examples then you need to install: gem install ruby-graphviz
If you did not alread install this for the Part 1 examples, then also:  gem install stemmer

== Using Firebug to Find HTML Elements on Web Pages:

You need to setup Firefox with the scripting plugin: follow the directions
in the book text and follow along with the book example.

== Using scRUBYt! to Web-Scrape CJsKitchen.com

Create the database tables:

ruby create_database_schema.rb

And the try running the remaining examples (most output is not shown):

$ ruby scrubyt_cjskitchen_test.rb 
Apple-Cranberry Chutney link: http://cjskitchen.com/printpage.jsp?recipe_id=1699880
Arroz con Pollo link: http://cjskitchen.com/printpage.jsp?recipe_id=13019321
Asian Chicken Rice link: http://cjskitchen.com/printpage.jsp?recipe_id=1360065
Barbecued Cornish Game Hens link: http://cjskitchen.com/printpage.jsp?recipe_id=8625327
Recipe: Apple-Cranberry Chutney
  Frozen cranberries : 1/3
  Granny Smith apple : 4/5
  Brown sugar : 1/8 cups
     ... etc. ...

$ ruby scrubit_cjskitchen_to_db.rb
** processing: printpage.jsp?recipe_id=1699880
recipe_url = printpage.jsp?recipe_id=1699880 and index=23
** processing: printpage.jsp?recipe_id=13019321
recipe_url = printpage.jsp?recipe_id=13019321 and index=23
** processing: printpage.jsp?recipe_id=1360065

etc. 

The PosgreSQL database created running watir_cookingspace_to_db.rb and scrubit_cjskitchen_to_db.rb
will be used for examples later in this book.

Chapter 11
==========

== Producing Linked Data Using D2R

Note: I saved the PostgreSQL database from Chapter 10 on the AMI in the
file ~/postgresql_test_db.txt  to restore: psql -U postgres test < postgresql_test_db.txt
The file postgresql_test_db.txt is also in src/part3/postgresql_test_db.txt

To run the D2R server:

~/d2r-server-0.6 $ ./generate-mapping -o mapping.n3 -d org.postgresql.Driver -u postgres jdbc:postgresql://localhost/test
~/d2r-server-0.6 $ ./d2r-server mapping.n3
14:53:57 INFO  log                  :: Logging to org.slf4j.impl.Log4jLoggerAdapter@2f1921 via org.mortbay.log.Slf4jLog
14:53:57 INFO  log                  :: jetty-6.1.10
14:53:57 INFO  log                  :: NO JSP Support for , did not find org.apache.jasper.servlet.JspServlet
14:53:57 INFO  D2RServer            :: using config file: file:/root/d2r-server-0.6/mapping.n3
14:53:59 INFO  log                  :: Started SocketConnector@0.0.0.0:2020
14:53:59 INFO  server               :: [[[ Server started at http://localhost:2020/ ]]]

To run the Ruby example D2R client:

~/src/part3/d2r_sparql_client $ ruby test_query.rb 
** _query: http://localhost:2020/sparql?query=%0APREFIX+rdfs%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0APREFIX+db%3A+%3Chttp%3A%2F%2Flocalhost%3A2020%2Fresource%2F%3E%0APREFIX+owl%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F2002%2F07%2Fowl%23%3E%0APREFIX+xsd%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F2001%2FXMLSchema%23%3E%0APREFIX+map%3A+%3Cfile%3A%2FUsers%2Fmarkw%2FDesktop%2Fd2r-server-0.6%2Fmapping.n3%23%3E%0APREFIX+rdf%3A+%3Chttp%3A%2F%2Fwww.w3.org%2F1999%2F02%2F22-rdf-syntax-ns%23%3E%0APREFIX+vocab%3A+%3Chttp%3A%2F%2Flocalhost%3A2020%2Fvocab%2Fresource%2F%3E%0A%0ASELECT+DISTINCT+%3Frecipe_name+%3Fingredient_name+%3Fingredient_amount+WHERE+%7B%0A++%3Frecipe_row+vocab%3Ascraped_recipes_recipe_name+%3Frecipe_name+.%0A++%3Frecipe_row+vocab%3Ascraped_recipes_id+%3Frecipe_id+.%0A++%3Fingredient_row+vocab%3Ascraped_recipe_ingredients_scraped_recipe_id+%3Frecipe_id+.%0A++%3Fingredient_row+vocab%3Ascraped_recipe_ingredients_description+%3Fingredient_name+.%0A++%3Fingredient_row+vocab%3Ascraped_recipe_ingredients_amount+%3Fingredient_amount+.%0A%7D%0ALIMIT+1%0A&
** _query: data: <?xml version="1.0"?>
<sparql xmlns="http://www.w3.org/2005/sparql-results#">
  <head>
    <variable name="recipe_name"/>
    <variable name="ingredient_name"/>
    <variable name="ingredient_amount"/>
  </head>
  <results>
    <result>
      <binding name="recipe_name">
        <literal>Apple</literal>
      </binding>
      <binding name="ingredient_name">
        <literal>salt</literal>
      </binding>
      <binding name="ingredient_amount">
        <literal>1 1/2 teaspoons</literal>
      </binding>
    </result>
  </results>
</sparql>
<?xml version="1.0"?>
<sparql xmlns="http://www.w3.org/2005/sparql-results#">
  <head>
    <variable name="recipe_name"/>
    <variable name="ingredient_name"/>
    <variable name="ingredient_amount"/>
  </head>
  <results>
    <result>
      <binding name="recipe_name">
        <literal>Apple</literal>
      </binding>
      <binding name="ingredient_name">
        <literal>salt</literal>
      </binding>
      <binding name="ingredient_amount">
        <literal>1 1/2 teaspoons</literal>
      </binding>
    </result>
  </results>
</sparql>


== Using Linked Data Sources (DBPedia)

The example client programs are in src/part3/dbpedia_client

For example, try running:

~/src/part3/dbpedia_client $ ruby test_query.rb 
** _query: http://dbpedia.org/sparql?query=%0ASELECT+distinct+%3Fname+%3Fperson+WHERE+%7B%0A%09%09%09+++%3Fperson+foaf%3Aname+%3Fname+.%0A%7D%0ALIMIT+5%0A&
** _query: data: <sparql xmlns="http://www.w3.org/2005/sparql-results#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2001/sw/DataAccess/rf1/result2.xsd">
 <head>
  <variable name="name"/>
  <variable name="person"/>
 </head>
 <results distinct="false" ordered="true">
  <result>
   <binding name="name"><literal>"A" Is for Alibi</literal></binding>
   <binding name="person"><literal>http://dbpedia.org/resource/%22A%22_Is_for_Alibi</literal></binding>
  </result>
      ...
 </results>
</sparql>


== Freebase

You need to:  gem install freebase

Change directory to src/part3/freebase_client and try:

~/src/part3/freebase_client $ ruby freebase_ruby_movie_genre.rb 
Movie genre: Animation
  Disney's American Legends
  The Simpsons Movie
  Star Wars: The Clone Wars
  Fantasia
     .... a few thousand lines are not shown ...

And, try:

~/src/part3/freebase_client $ ruby freebase_ruby.rb 
name of asteroid=433 Eros
spectral type=S-type asteroid

"a_slogan:"
#<#<Freebase::Types::Business::AdvertisingSlogan brand:/business/brand_slogan>:0xb7a848d4
 @result=
  {:type=>"/business/advertising_slogan",
   :brand=>
    [{"name"=>nil,
      "id"=>"/guid/9202a8c04000641f800000000bffcd1a",
      "type"=>["/business/brand_slogan"]}],
   :timestamp=>
    [{"value"=>"2006-10-23T12:52:53.0000Z", "type"=>"/type/datetime"}],
   :guid=>[{"value"=>"#9202a8c04000641f800000000082723d", "type"=>"/type/id"}],
   :permission=>
    [{"name"=>"Global Write Permission",
      "id"=>"/boot/all_permission",
      "type"=>["/type/permission"]}],
   :creator=>
    [{"name"=>"Freebase Staff",
      "id"=>"/user/metaweb",
      "type"=>["/type/user"]}],
   :key=>
    [{"namespace"=>"/wikipedia/en_id",
      "value"=>"2822353",
      "type"=>"/type/key"},
     {"namespace"=>"/wikipedia/en",
      "value"=>"Keep_Austin_Weird",
      "type"=>"/type/key"},
     {"namespace"=>"/en", "value"=>"keep_austin_weird", "type"=>"/type/key"}],
   :attribution=>
    [{"name"=>"Freebase Staff",
      "id"=>"/user/metaweb",
      "type"=>["/type/user"]}],
   :name=>"Keep Austin Weird",
   :id=>[{"value"=>"/en/keep_austin_weird", "type"=>"/type/id"}]}>
name=Keep Austin Weird
creator=/user/metaweb
Number of slogans = 15
  Keep Austin Weird : /user/metaweb
  It had to be good to get where it is. : /user/skud
  Thirst knows no season. : /user/skud
  Pure as sunlight. : /user/skud
  Coca-Cola revives and sustains. : /user/skud
  Refresh yourself. : /user/skud
  Six million a day. : /user/skud
  Enjoy life. : /user/skud
  Delicious and refreshing : /user/skud
  Drink Coca Cola : /user/skud
  Good til the last drop. : /user/skud
  Three million a day. : /user/skud
  The great national temperance beverage. : /user/skud
  What happens in Vegas, stays in Vegas : /user/dylanrocks
  Be Bad.Drink Good. : /user/razzledazzle


== Open Calais

If you do nat already have it installed:   gem install simplehttp

You also need to set you Open Calias developer key, then you can run the sample program
in the src/part3/open_calais_linked_data directory:

~/src/part3/open_calais_linked_data $ export OPEN_CALAIS_KEY="PUT YOUR KEY HERE"
root@domU-12-31-39-03-02-57:~/src/part3/open_calais_linked_data# ruby use_linked_data.rb "people:"
[["http://d.opencalais.com/pershash-1/cfcf1aa2-de05-3939-a7d5-10c9c7b3e87b",
  "Barack Obama"],
 ["http://d.opencalais.com/pershash-1/63b9ca66-bfdb-3533-9a19-8b1110336b5c",
  "George Bush"]]
"places:"
[["http://d.opencalais.com/er/geo/city/ralg-geo1/797c999a-d455-520d-e5cf-04ca7fb255c1",
  "Paris,France"],
 ["http://d.opencalais.com/er/geo/city/ralg-geo1/f08025f6-8e95-c3ff-2909-0a5219ed3bfa",
  "London,Greater London,United Kingdom"],
 ["http://d.opencalais.com/er/geo/country/ralg-geo1/e165d4f2-174b-66a7-d1a9-5cb204d296eb",
  "France"],
 ["http://d.opencalais.com/genericHasher-1/56fc901f-59a3-3278-addc-b0fc69b283e7",
  "Paris"],
 ["http://d.opencalais.com/genericHasher-1/e1fd0a20-f464-39be-a88f-25038cc7f50c",
  "France"],
 ["http://d.opencalais.com/genericHasher-1/6fda72fd-105c-39ba-bb79-da95785a249f",
  "London"]]
"companies:"
[["http://d.opencalais.com/er/company/ralg-tr1r/9e3f6c34-aa6b-3a3b-b221-a07aa7933633",
  "International Business Machines Corporation"],
 ["http://d.opencalais.com/comphash-1/7c375e93-de13-3f56-a42d-add43142d9d1",
  "IBM"]]



Chapter 12
----------

== Database scalign sections:

No program examples

== Using memcached with ActiveRecord

You need to install 2 gems:

gem install system_timer
gem install Ruby-MemCache

You need to have memcached installed, and run it as a service:

memcached -d

Try:

$ cd src/part3/memcached

$ ruby memcached_client_example.rb 
Ruby Web Sites:
["http://www.ruby-lang.org/en/"]
Ruby Web Sites:
["http://www.ruby-lang.org/en/", "http://www.ruby-lang.org/en/libraries/"]
[1, 2, 3.14159]
0
{"cat"=>"dog"}
NilClass

Assuming that the test database is setup from previous examples, try:

$ ruby activerecord_wrapper_example.rb 
id 1 not in cache
id 2 not in cache
http://test.com/bigwave123 http://test.com/bigfish
http://test.com/bigwave123 http://test.com/bigfish
modified url for first article: http://test.com/bigwave649

For the web services example, follow the instructions in the book for running the
test web server, then try:    ruby web_services_wrapper_example.rb

== Using CouchDB

Install the gem:   gem install couchrest simple-rss atom  rubyzip

On my Linux servers (including the AMI that I set up for you - see Appendix A)
I startup CouchDB using:   sudo /etc/init.d/couchdb start

On my MacBook, I run a standalone CouchDB application that has a Mac GUI.

Once you have a CouchDB service running, try:

$ cd src/part3/couchdb_client
$ ruby couchdb_test.rb 
"response:"
{"rev"=>"2507158567", "id"=>"c0fe270e73026b9eb5e89c04613210dc", "ok"=>true}
{"_rev"=>"2507158567",
 "_id"=>"c0fe270e73026b9eb5e89c04613210dc",
 "key 1"=>"value 1",
 "key 2"=>[1, 2, 3.14159, "a string"]}
{"total_rows"=>1,
 "rows"=>
  [{"id"=>"c0fe270e73026b9eb5e89c04613210dc",
    "value"=>{"rev"=>"2507158567"},
    "key"=>"c0fe270e73026b9eb5e89c04613210dc"}],
 "offset"=>0}

Note, for some versions of the gem, the method "save_doc" may be "save".

No try saving Wikipedia articles, and reloading them:

root@domU-12-31-39-03-02-57:~/src/part3/couchdb_client# ruby wikipedia_to_couchdb.rb
++ entered PlainTextResource constructor
++ entered TextResource constructor
++ entered PlainTextResource constructor
++ entered TextResource constructor
doc id: a17bfb348ec97309a622f121f3c85050
doc id: 30b7b0ab297732f492c2288bebef2fc6
root@domU-12-31-39-03-02-57:~/src/part3/couchdb_client# ruby wikipedia_from_couchdb.rb
test_data/wikipedia_Hillary Rodham Clinton.txt
2][3] She was raised in a United Methodist family, first in Chicago, and then, from the age of three, in suburban Park Ridge, Illinois. in Chicago in 1962.[16] In 1965, Rodham enrolled at Wellesley College, where she majored in political science. House of Representatives in his home state.
0.015532171617488
Hillary Diane Rodham Clinton .....
  .... hundreds of lines of output are not shown here ....

I used the TextResource classes from Part 1 in this example.


== Using Amazon S3

Set you S3 account information in your environment, as per the directions in the book, then try:

$ cd src/part3/amazon-s3
$ ruby s3_test.rb 
[#<AWS::S3::Bucket:0x1cec920 
  @attributes= 
   {"name"=>"markbookimage", "creation_date"=>Sat Mar 28 19:53:47 UTC 2009}, 
  @object_cache=[]>]
#<AWS::S3::Bucket:0x1cdec94 @object_cache=[], @attributes={"prefix"=>nil, "name"=>"web3_chapter12", "marker"=>nil, "max_keys"=>1000, "is_truncated"=>false}
   .... not all output shown ....


== Using Amazon EC2

No program examples in this section










