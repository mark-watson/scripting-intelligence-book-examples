

def cluster_strings *text_strings
  @texts = []
  text_strings.each {|text|
    tokens = text.downcase.scan(/[a-z]+/)
    @texts << tokens
  }
  # create a two-dimensioanl array [doc index][doc_index]:
  size = @texts.length
  similarity_matrix = Array.new(size)
  similarity_matrix.map! {
    temp = Array.new(size)
    temp.size.times {|i| temp[i] = 0}
    temp
  }
  size.times {|i|
    size.times {|j|
      common_tokens = @texts[i] & @texts[j]
      similarity_matrix[i][j] = 2.0 * common_tokens.length.to_f / (@texts[i].length + @texts[j].length)
    }
  }
  # calculate possible clusters:
  cluster = []
  size.times {|i|
    similar = []
    size.times {|j|
      similar << j if j > i && similarity_matrix[i][j] > 0.1
    }
    cluster << (similar << i).sort if similar.length > 0
  }
  # remove redundent clusters:
  cluster.size.times {|i|
    cluster.size.times {|j|
      if cluster[j].length < cluster[i].length
        cluster[j] = [] if (cluster[j] & cluster[i]) == cluster[j]
      end
    }
  }
  result = []
  cluster.each {|c| result << c if c.length > 1}
  result
end


require 'pp'

def word_use_similarity text1, text2
  tokens1 = text1.downcase.scan(/[a-z]+/)
  tokens2 = text2.downcase.scan(/[a-z]+/)
  common_tokens = tokens1 & tokens2
  common_tokens.length.to_f / (tokens1.length + tokens2.length)
end

s1="Software products"
s2="Hardware products"
s3="misc words matching nothing"
s4="Software and Hardware products"
s5="misc stuff"
#wc = cluster_strings(s1, s2, s3, s4, s5)
#pp wc

#puts word_use_similarity(s1, s1)

#puts word_use_similarity(s1, s2)
#puts word_use_similarity(s1, s3)
#puts word_use_similarity(s2, s3)
#puts word_use_similarity(s2, s1)

