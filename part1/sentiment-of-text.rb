require 'classifier_word_count_statistics'

class ClassifierWordCountStatistics
  def get_sentiment text
    word_stems = text.downcase.scan(/[a-z]+/)
    scores = Array.new(2)
    2.times {|i|
      scores[i] = score(@category_wc_hashes[i], word_stems)
    }
    scores[0] - scores[1]
  end
end

class SentimentOfText
  def initialize
    @classifier = ClassifierWordCountStatistics.new
    @classifier.train([['data/positive.txt', "Positive sentiment"],
                       ['data/negative.txt', "Negative sentiment"]])
  end
  def get_sentiment text
    @classifier.get_sentiment(text)
  end
end

require 'pp'

st = SentimentOfText.new
pp st.get_sentiment("the boy kicked the dog")
pp st.get_sentiment("the boy greeted the dog")
pp st.get_sentiment("greeted greeted   ")
