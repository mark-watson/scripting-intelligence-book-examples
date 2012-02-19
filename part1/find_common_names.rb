## Example application using the TextResource class and
## sub-classes: find common names in two or more text sources

require 'pp'
require 'entity_extraction'

def find_common_names *file_paths
   names_texts = file_paths.map{|file_path| File.new(file_path).read}
   extractors = names_texts.map{|file_path| EntityExtraction.new(file_path)}

   names_lists = extractors.map{|extractor| extractor.human_names}
   common_names = names_lists.pop
   names_lists.each {|nlist| common_names = common_names & nlist}
   
   places_lists = extractors.map{|extractor| extractor.place_names}
   common_places = places_lists.pop
   places_lists.each {|nlist| common_places = common_places & nlist}

   [common_names, common_places]
end

pp find_common_names("test_data/wikipedia_Hillary Rodham Clinton.txt", "test_data/wikipedia_Barack_Obama.txt")
