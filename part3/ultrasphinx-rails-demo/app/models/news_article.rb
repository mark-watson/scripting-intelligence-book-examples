class NewsArticle < ActiveRecord::Base
  is_indexed :fields => ['title', 'contents']
end
