require 'rubygems' #required for Ruby 1.8.6
require "freebase"

all_genres = Freebase::Types::Film::FilmGenre.find(:all)
all_genres.each {|genre|
  puts "Movie genre: #{genre.name}"
  begin
    genre.films_in_this_genre.each {|film| puts "  #{film.name}"}
  rescue
    puts "Error: #{$!}"
  end
}
