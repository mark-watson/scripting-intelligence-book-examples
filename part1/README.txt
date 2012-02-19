Book Examples for PART 1
------------------------

Required gems:

gem install nokogiri stemmer classifier simplehttp clusterer simple-rss atom rubyzip --no-rdocs --no-ri

If you want to use the spelling example, you will need to install the ASpell utilities
if they are not already on your system. Run the command "aspell" to see if it is
already installed; if not, here is a link: http://aspell.net/man-html/Installing.html

On Mac OS X, you can install the MacPorts utility, then do:
sudo port install aspell

On most Linu systems, you can install ASpell using:

apt-get install aspell
sudo port install aspell-dict-en

Chapter 1
---------

If you install the gems required for Part 1 and if you change directory to src/part1, then
Chapter 1 examples in the book should run as described in the book. For example:

markws-macbook:part1 markw$ irb
irb(main):001:0> require 'rubygems' # only needed for Ruby 1.8.x
=> true
irb(main):002:0> require 'nokogiri'
=> true
irb(main):003:0> require 'open-uri'
=> true
irb(main):004:0> doc = Nokogiri::HTML(open('http://markwatson.com'))
=> <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--[if IE]>
<style type="text/css" media="screen">
    ... ETC. ...

Note: the class TextResurce (and subclasses of TextResource) are incrementally
developed in Chapters 1, 2, and 3. I will wait for the section on Chapter 3
later in this file to show you TextResource examples:


Chapter 2
---------

== HTML CLeanup:

markws-macbook:part1 markw$ irb
irb(main):001:0> html = "<h1>test heading</h1>Test <b>bold</a> text." 
=> "<h1>test heading</h1>Test <b>bold</a> text."
irb(main):002:0> html.gsub(/<\/?[^>]*>/, "")
=> "test headingTest bold text."
irb(main):003:0> html.gsub(/<\/?[^>]*>/, " ").gsub('  ', ' ').gsub('  ', ' ')
=> " test heading Test bold text."
irb(main):004:0> require 'cleanup'
test 1 2 3
test 1 2 3regular text
test 1 2 3
regular text
 header 1 This   is
  a test 	 1 2 3. 
header 1 This is a test 1 2 3.
=> true
irb(main):005:0> clean_up html
 test heading Test  bold  text.
=> "test heading Test bold text."
irb(main):006:0> 


Breaking text into separate sentences: code in book is in file text-resource.rb

== Stemming text:

markws-macbook:part1 markw$ irb
irb(main):001:0> require 'rubygems' # needed for Ruby 1.8.*
=> true
irb(main):002:0> require 'stemmer'
=> true
irb(main):003:0> "banking".stem
=> "bank"
irb(main):004:0> "tests testing tested".split.collect {|word| word.stem}
=> ["test", "test", "test"]
irb(main):005:0> 


== Spelling:

markws-macbook:part1 markw$ irb
irb(main):001:0> require 'spelling'
=> true
irb(main):002:0> require 'pp'
=> true
irb(main):003:0> pp get_spelling_correction_list("waalkiing") 
["walking", "walling", "weakling", "waking", "waling", "welkin"]
=> nil
irb(main):004:0>


== Cleanup noise words:

This example uses the file big.txt from file from Peter Norvig's web page: http://norvig.com/spell-correct.html

$ irb
irb(main):001:0> require 'remove_noise_characters'
"B6 E7 A1 A4 E8 1 0 0 1 25 778 Tm 0.0675 Tc 0.4728 Tw your physician or any information contained on or in any product Tj ET Q q rdf li rdf parseType Resource stMfs linkForm ReferenceStream stMfs linkForm rdf li ASRvt0pXp xA;giCZBEY8KEtLy3EHqi4q5NVVd IH qDXDkxkHkyO6jdaxJJcpCUYQTkoZCDsD3p03plkMVxJvdQK xA; TXSkUGaCONfTShqNieQ9 vXISs7sJmmC mNogVWvYAx40LA0oabd Heading 3 CJOJQJ JaJ A R h l In an effort to ensure timely bjbjUU 7 7 l"
". your physician or any information contained on or in any product ; an effort to ensure timely "
=> true
irb(main):002:0> str = File.open("noise.txt").read
=> "<B6><E7><A1>&<A4><E8>\n1 0 0 1 25 778 Tm\n-0.0675 Tc\n0.4728 Tw\n(your physician or any information contained on or in any product ) Tj\nET\nQ\nq\n   <rdf:li rdf:parseType=\"Resource\">\n     <stMfs:linkForm>ReferenceStream</stMfs:linkForm>\n   </rdf:li>\nASRvt0pXp&#xA;giCZBEY8KEtLy3EHqi4q5NVVd+IH+qDXDkxkHkyO6jdaxJJcpCUYQTkoZCDsD3p03plkMVxJvdQK&#xA;\nTXSkUGaCONfTShqNieQ9+vXISs7sJmmC/mNogVWvYAx40LA0oabd\n  Heading 3$???<@&?CJOJQJ?^JaJ<A@???<\n    R?h?l\nIn an effort to ensure timely\nbjbjUU\t\"7|7|???????l???????????\n\n\n"
irb(main):003:0> s1 = remove_noise_characters(str)
=> "B6 E7 A1 A4 E8 1 0 0 1 25 778 Tm 0.0675 Tc 0.4728 Tw your physician or any information contained on or in any product Tj ET Q q rdf li rdf parseType Resource stMfs linkForm ReferenceStream stMfs linkForm rdf li ASRvt0pXp xA;giCZBEY8KEtLy3EHqi4q5NVVd IH qDXDkxkHkyO6jdaxJJcpCUYQTkoZCDsD3p03plkMVxJvdQK xA; TXSkUGaCONfTShqNieQ9 vXISs7sJmmC mNogVWvYAx40LA0oabd Heading 3 CJOJQJ JaJ A R h l In an effort to ensure timely bjbjUU 7 7 l"
irb(main):004:0> s2 = remove_words_not_in_spelling_dictionary(s1)
=> ". your physician or any information contained on or in any product ; an effort to ensure timely "
irb(main):005:0> 

* note: I did not include the noise word removal methods in TextResource. You
        can remove the stubs in TextResource and replace with the code
        in remove_noise_characters.rb if you need this functionality



Chapter 3
---------

== Classifier using word counts:

$ irb
irb(main):001:0> require 'classifier_word_count_statistics'
"Health"
=> true
irb(main):002:0> test = ClassifierWordCountStatistics.new
=> #<ClassifierWordCountStatistics:0x3595bc @category_names=[], @noise_words=["the", "a", "at", "he", "she", "it"], @category_wc_hashes=[]>
irb(main):003:0> test.train([['wikipedia_text/computers.txt', "Computers"],
irb(main):004:2*             ['wikipedia_text/economy.txt', "Economy"],
irb(main):005:2*             ['wikipedia_text/health.txt', "Health"],
irb(main):006:2*             ['wikipedia_text/software.txt', "Software"]])
=> [["wikipedia_text/computers.txt", "Computers"], ["wikipedia_text/economy.txt", "Economy"], ["wikipedia_text/health.txt", "Health"], ["wikipedia_text/software.txt", "Software"]]
irb(main):007:0> require 'pp'
=> false
irb(main):008:0> pp test.classify_plain_text("Heart attacks and strokes kill too many people every year.")
"Health"
=> nil
irb(main):009:0> 


== Classifier using Bayesian classifier gem:

$ irb
irb(main):001:0> require 'classifier_bayesian_using_classifier_gem'
Notice: for 10x faster LSI support, please install http://rb-gsl.rubyforge.org/
=> true
irb(main):002:0> test = BayesianClassifier.new 
=> #<BayesianClassifier:0x396ea8>
irb(main):003:0> test.train([['wikipedia_text/computers.txt', "Computers"],
irb(main):004:2* ['wikipedia_text/economy.txt', "Economy"], 
irb(main):005:2* ['wikipedia_text/health.txt', "Health"], 
irb(main):006:2* ['wikipedia_text/software.txt', "Software"]])
=> [["wikipedia_text/computers.txt", "Computers"], ["wikipedia_text/economy.txt", "Economy"], ["wikipedia_text/health.txt", "Health"], ["wikipedia_text/software.txt", "Software"]]
irb(main):007:0> puts test.classify_plain_text(" 
irb(main):008:1" Heart attacks and strokes kill too many people every year.")
Health
=> nil
irb(main):009:0> 


== Using LSI for Categorization:

$ irb
irb(main):001:0> require 'classifier_lsa_using_classifier_gem'
Notice: for 10x faster LSI support, please install http://rb-gsl.rubyforge.org/
=> true
irb(main):002:0> test = LatentSemanticAnalysisClassifier.new
=> #<LatentSemanticAnalysisClassifier:0x11ea1e4>
irb(main):003:0> test.train([['wikipedia_text/computers.txt', "Computers"],
irb(main):004:2*             ['wikipedia_text/economy.txt', "Economy"],
irb(main):005:2*             ['wikipedia_text/health.txt', "Health"],
irb(main):006:2*             ['wikipedia_text/software.txt', "Software"]])
=> 4
irb(main):007:0> test.classify_plain_text("Heart attacks and strokes kill too many people every year.")
=> "Computers"
irb(main):008:0> test.classify_plain_text("Economic warfare rich versus the poor over international monetary fund.")
=> "Economy"
irb(main):009:0> test.classify_plain_text("My IBM PC broke so I bought an HP.")
=> "Computers"
irb(main):010:0> text = File.new('wikipedia_text/health.txt').read[0..700]
=> "In 1948, the World Health Assembly defined health as \342\200\234a state of complete physical, mental, and social well-being and not merely the absence of disease or infirmity.\342\200\235 [1][2] This definition is still widely referenced, but is often supplemented by other World Health Organization (WHO) reports such as the Ottawa Charter for Health Promotion which in 1986 stated that health is \342\200\234a resource for everyday life, not the objective of living. Health is a positive concept emphasizing social and personal resources, as well as physical capacities.\342\200\235\n\nClassification systems describe health. The WHO\342\200\231s Family of International Classifications (WHO-FIC) is composed of the International Classification "
irb(main):011:0> test.get_summary(text)
=> "\342\200\235 [1][2] This definition is still widely referenced, but is often supplemented by other World Health Organization (WHO) reports such as the Ottawa Charter for Health Promotion which in 1986 stated that health is \342\200\234a resource for everyday life, not the objective of living. In 1948, the World Health Assembly defined health as \342\200\234a state of complete physical, mental, and social well-being and not merely the absence of disease or infirmity"
irb(main):012:0> 


== Using Bayesian Classification and LSI Summarization:


$ irb
irb(main):002:0> require 'classification_and_summarization_using_classifier_gem' 
Notice: for 10x faster LSI support, please install http://rb-gsl.rubyforge.org/
irb(main):003:0> test = ClassifierAndSummarization.new
=> #<ClassifierAndSummarization:0x3877a0>
irb(main):004:0> test.train([['wikipedia_text/computers.txt', "Computers"],
irb(main):005:2*             ['wikipedia_text/economy.txt', "Economy"],
irb(main):006:2*             ['wikipedia_text/health.txt', "Health"],
irb(main):007:2*             ['wikipedia_text/software.txt', "Software"]])
=> [["wikipedia_text/computers.txt", "Computers"], ["wikipedia_text/economy.txt", "Economy"], ["wikipedia_text/health.txt", "Health"], ["wikipedia_text/software.txt", "Software"]]
irb(main):008:0> test.classify_plain_text("Heart attacks and strokes kill too many people every year.")
=> "Health"
irb(main):009:0> text = File.new('wikipedia_text/health.txt').read[0..700]
=> "In 1948, the World Health Assembly defined health as \342\200\234a state of complete physical, mental, and social well-being and not merely the absence of disease or infirmity.\342\200\235 [1][2] This definition is still widely referenced, but is often supplemented by other World Health Organization (WHO) reports such as the Ottawa Charter for Health Promotion which in 1986 stated that health is \342\200\234a resource for everyday life, not the objective of living. Health is a positive concept emphasizing social and personal resources, as well as physical capacities.\342\200\235\n\nClassification systems describe health. The WHO\342\200\231s Family of International Classifications (WHO-FIC) is composed of the International Classification "
irb(main):010:0> test.classify_and_summarize_plain_text(text)
=> ["Health", "\342\200\235 [1][2] This definition is still widely referenced, but is often supplemented by other World Health Organization (WHO) reports such as the Ottawa Charter for Health Promotion which in 1986 stated that health is \342\200\234a resource for everyday life, not the objective of living. In 1948, the World Health Assembly defined health as \342\200\234a state of complete physical, mental, and social well-being and not merely the absence of disease or infirmity"]
irb(main):012:0> 


== Extracting Entities From Text:

$ irb
irb(main):001:0> require 'entity_extraction'
=> true
irb(main):002:0> ee = EntityExtraction.new('President George W. Bush left office and Barack Obama 
irb(main):003:1' was sworn in as president and went to Florida with his family to stay 
irb(main):004:1' at Disneyland.')
=> #<EntityExtraction:0x2498cdc @human_names=["President George W Bush", "Barack Obama"], @place_names=["Florida"]>
irb(main):005:0> ee.human_names
=> ["President George W Bush", "Barack Obama"]
irb(main):006:0> ee.place_names
=> ["Florida"]
irb(main):007:0> 



== Performing Entity Extraction Using Open Calais:

As per the discusion in the book, you need to getan Open Calais account (free)
and set an environment variable OPEN_CALAIS_KEY to the value of your key.

$ irb
irb(main):001:0> require 'rubygems' # only for Ruby 1.8.x
=> true
irb(main):002:0> require 'calais_client'
=> true
irb(main):003:0> s = "Hillary Clinton and Barack Obama campaigned in Texas. Both want to live 
irb(main):004:0" in the White House. Pepsi sponsored both candidates." 
=> "Hillary Clinton and Barack Obama campaigned in Texas. Both want to live \nin the White House. Pepsi sponsored both candidates."
irb(main):005:0> cc = CalaisClient::OpenCalaisTaggedText.new(s)
=> #<CalaisClient::OpenCalaisTaggedText:0x1283e0c @response="<?xml version=\"1.0\" 

   ... lots of output is not shown here ...

irb(main):006:0> cc.get_tags
=> {"Person"=>["Barack Obama", "Hillary Clinton"], "City"=>nil, "Country"=>nil, "Company"=>["Pepsi"], "State"=>["Texas"], "Organization"=>["White House"]}
irb(main):016:0> 


== Determining the “Sentiment” of Text:

$ irb
irb(main):001:0> require 'sentiment-of-text'
=> true
irb(main):002:0> st = SentimentOfText.new
=> #<SentimentOfText:0x377fe4 @classifier=#<ClassifierWordCountStatistics:0x377fbc @noise_words=["the", "a", "at", "he", "she", "it"], @category_names=["Positive sentiment", "Negative sentiment"], @category_wc_hashes=[{"onset"=>0.000718390804597701, "revel"=>0.000718390804597701,

   ... lots of output is not shown here ...

irb(main):003:0> st.get_sentiment("the boy kicked the dog") 
=> -0.11648223645894
irb(main):004:0> st.get_sentiment("the boy greeted the dog")
=> 0.14367816091954
irb(main):005:0> 


== K-means Document Clustering:

$ irb
irb(main):001:0> require 'rubygems' # needed for Ruby 1.8.x
=> true
irb(main):002:0> require 'clusterer'
For faster LSI support, please install Linalg: 
=> true
>> text1 = File.new('wikipedia_text/computers.txt').read 
=> "A computer is a machine..." 
>> text2 = File.new('wikipedia_text/economy.txt').read 
=> "\nEconomy\nFrom Wikipedia, the ..." 
>> text3 = File.new('wikipedia_text/health.txt').read 
=> "In 1948, the World Health Assembly ..." 
>> text4 = File.new('wikipedia_text/software.txt').read 
=> "Software is a general term ..." 
>> doc1 = Clusterer::Document.new(text1) 
=> {"png"=>1, "earlier"=>2, 
>> doc2 = Clusterer::Document.new(text2) 
=> {"earlier"=>1, "parasit"=>1, 
>> doc3 = Clusterer::Document.new(text3) 
=> {"multidisciplinari"=>1, "behavior"=>2, 
>> doc4 = Clusterer::Document.new(text4) 
=> {"w3c"=>1, "whole"=>1, "lubarski"=>1, 
>> cluster = Clusterer::Clustering.cluster(:kmeans,[doc1, doc2, doc3, doc4], 
:no_of_clusters => 3) 
Iteration ....0 
Iteration ....1 
=> [#<Clusterer::Cluster:0x2249e90 @documents=[{    .... .....
>> cluster[0].documents.each {|doc| puts doc.object_id} ; :ok 
 18078930 
17997460 
 => :ok



== Combining the TextResource Class with NLP Code:

In the book text, I integrated the NLP code for Chapter 3 into the TextResource class.

Here is the application example in the text:

require 'text-resource' 
def find_common_names *file_paths 
   names_lists = 
      file_paths.map {|file_path| 
        PlainTextResource.new(file_path).human_names
      } 
   common_names = names_lists.pop 
   names_lists.each {|nlist| common_names = common_names & nlist} 
   common_names 
end

Running this example yields this output:

irb(main):011:0> find_common_names("test_data/wikipedia_Hillary Rodham Clinton.txt", 
                                   "test_data/wikipedia_Barack_Obama.txt")
=> ["Barack Obama", "John McCain"]


	



