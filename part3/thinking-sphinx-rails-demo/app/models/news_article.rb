class NewsArticle < ActiveRecord::Base
  define_index do
    indexes [:title, :contents]
  end
end
