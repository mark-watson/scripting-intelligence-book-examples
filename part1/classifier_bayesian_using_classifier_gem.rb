require 'rubygems'
require 'classifier'

class BayesianClassifier
  def classify_plain_text text
    @bayes.classify(text)
  end
  def train file_and_topic_list
    topic_names = file_and_topic_list.collect {|x| x.last}
    @bayes = Classifier::Bayes.new(*topic_names)
    file_and_topic_list.each {|file, category|
      text = File.new(file).read
      @bayes.train(category, text)
    }
  end
end

test = BayesianClassifier.new
test.train([['wikipedia_text/computers.txt', "Computers"],
            ['wikipedia_text/economy.txt', "Economy"],
            ['wikipedia_text/health.txt', "Health"],
            ['wikipedia_text/software.txt', "Software"]])
require 'pp'
pp test.classify_plain_text("Heart attacks and strokes kill too many people every year.")
