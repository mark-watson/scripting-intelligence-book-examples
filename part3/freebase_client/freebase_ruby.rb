require 'rubygems'
require "freebase"
require 'pp'

an_asteroid = Freebase::Types::Astronomy::Asteroid.find(:first)
#pp "an_asteroid:", an_asteroid
puts "name of asteroid=#{an_asteroid.name}"
puts "spectral type=#{an_asteroid.spectral_type[0].name}"

#all_asteroids = Freebase::Types::Astronomy::Asteroid.find(:all)
#pp "all_asteroids:", all_asteroids

#an_industry = Freebase::Types::Business::Industry.find(:first)
#pp "an_industry:", an_industry
#puts "name=#{an_industry.name}"
#puts "parent company name=#{a_company.parent_company[0].name}"

puts "\n\n"

a_slogan = Freebase::Types::Business::AdvertisingSlogan.find(:first)
pp "a_slogan:", a_slogan
puts "name=#{a_slogan.name}"
puts "creator=#{a_slogan.creator}"

all_slogans = Freebase::Types::Business::AdvertisingSlogan.find(:all)
puts "Number of slogans = #{all_slogans.length}"
all_slogans.each {|slogan|  puts "  #{slogan.name} : #{slogan.creator}"}
#pp (Freebase::Types::Business.public_methods - Object.public_methods).sort

