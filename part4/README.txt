Part 4 Example Programs
-----------------------


Chapter 13
----------

You do **not** need to install the plugin:
ruby script/plugin install svn://rubyforge.org/var/svn/ym4r/Plugins/GM/trunk/ym4r_gm
because I have already installed it in the example Rails web application directory:

  src/part4/mashup_web_app

You do need to set up your Twitter account information and get a free Google
Maps developers key -- follow the instructions in the book.

Then try:

cd src/part4/mashup_web_app
script/server


Chapter 14
----------

== Using the Distributed Map/Reduce Algorithm

There are no program examples in this section.

== Installing Hadoop

There are no program examples in this section.

== Writing Map/Reduce Functions Using Hadoop Streaming

Follow  the instructions in the book for setting up a single server development
environment. If you are using my AMI, then the complete setup can be found in
the directory ~/hadoop-0.18.3 when you ssh login to an EC2 instance using my AMI.

If you are settinh up Hadoop from scratch on your laptop: follow the instructions
in the book (or on the Hadoop web site), and then copy in my sample Ruby and Java
map reduce code located at:

  src/part4/Ruby_map_reduce_scripts.zip
  src/part4/namefinder.jar

Hadoop reads input files from the directory input and writes them to the
directory output. The output directory can not already exist when starting
a Hadoop run.

Try this (the absolute path to map reduce scripts is required; here I have the paths as
they are on my MacBook - you will need to change these paths):

cd hadoop-0.18.3

markws-macbook:hadoop-0.18.3 markw$ ls *.rb
map.rb          peoplemap.rb    peoplereduce.rb reduce.rb
markws-macbook:hadoop-0.18.3 markw$ bin/hadoop jar contrib/streaming/hadoop-0.18.3-streaming.jar  
markws-macbook:hadoop-0.18.3 markw$ rm -r -f output/
markws-macbook:hadoop-0.18.3 markw$ bin/hadoop jar contrib/streaming/hadoop-0.18.3-streaming.jar  -mapper map.rb -reducer reduce.rb -input input/* -output output -file /Users/markw/Documents/WORK/hadoop-0.18.3/map.rb -file /Users/markw/Documents/WORK/hadoop-0.18.3/reduce.rb
additionalConfSpec_:null
null=@@@userJobConfProps_.get(stream.shipped.hadoopstreaming
packageJobJar: [/Users/markw/Documents/WORK/hadoop-0.18.3/map.rb, /Users/markw/Documents/WORK/hadoop-0.18.3/reduce.rb] [] /tmp/streamjob31369.jar tmpDir=null
09/06/06 14:15:34 INFO jvm.JvmMetrics: Initializing JVM Metrics with processName=JobTracker, sessionId=
09/06/06 14:15:34 WARN mapred.JobClient: Use GenericOptionsParser for parsing the arguments. Applications should implement Tool for the same.
09/06/06 14:15:34 INFO mapred.FileInputFormat: Total input paths to process : 2
09/06/06 14:15:34 INFO mapred.FileInputFormat: Total input paths to process : 2
09/06/06 14:15:35 INFO mapred.FileInputFormat: Total input paths to process : 2
09/06/06 14:15:35 INFO mapred.FileInputFormat: Total input paths to process : 2
09/06/06 14:15:35 INFO streaming.StreamJob: getLocalDirs(): [/tmp/hadoop-markw/mapred/local]

  .... lots of output is not shown ....

09/06/06 14:15:36 INFO mapred.TaskRunner: Task 'attempt_local_0001_r_000000_0' done.
09/06/06 14:15:36 INFO mapred.TaskRunner: Saved output of task 'attempt_local_0001_r_000000_0' to file:/Users/markw/Documents/WORK/hadoop-0.18.3/output
09/06/06 14:15:37 INFO streaming.StreamJob:  map 100%  reduce 100%
09/06/06 14:15:37 INFO streaming.StreamJob: Job complete: job_local_0001
09/06/06 14:15:37 INFO streaming.StreamJob: Output: output
markws-macbook:hadoop-0.18.3 markw$ 

To see the output of this very small test run:

markws-macbook:hadoop-0.18.3 markw$ cat output/part-00000 
Bob	doc2 doc3 doc4 doc3
Brown	doc3 doc2
John	doc3 doc4
Jones	doc3

  .... not all output is shown

was	doc3
went	doc3 doc2

To run the Java map reduce example, change the name of the directory "input" to
"input_save_small_sample" and change the name of the directory "input_wikipedia"
to "input" to use the very large Wikipedia data set. Then try:

rm -r -f output/
bin/hadoop jar namefinder.jar com.knowledgebooks.mapreduce.NameFinder -m 1 -r 1 input/ output/

Following the directions at the end of Chapter 14 you can also run this large test case using
Amazon's Electric MapReduce service.




Chapter 15
----------


== Searching for People’s Names on Wikipedia

This uses the large map reduce run from the end of Chapter 14. I include the results of the
large map reduce run in the IP file: src/part4/wikipedia_name_finder_web_app/db/mapreduce_results.zip

When you run a "rake db:migrate" this ZIP file will be read (no need to unZIP it!) and the
data loaded in a local database. Before you run the migration, create the database:

$ mysql
mysql> create database wikipedia_name_links_development;
Query OK, 1 row affected (0.00 sec)
mysql> quit;

Note: if you are running my AMI, then I have already created the database and
run "rake db:migrate" so you do not need to do this again.

Then, run as usual:

script/server

When I run this on my AMI, I reference a URL that looks like this:

  http://ec2-174-129-145-14.compute-1.amazonaws.com:3000/

but the actual public DNS name is different every time I start
up a new EC2 instance running my AMI.


== A Personal "Interesting Things" Web Application

This Rails web application is in the directory:  src/part4/interesting_things_web_app

The only thing that you need to do before running it is to create a
database named "interesting_things_development" and run "rake db:migrate"

