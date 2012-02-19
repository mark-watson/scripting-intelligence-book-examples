require 'pp'
require 'twitter'
T_ACCOUNT=ENV['TWITTER_ACCOUNT']
T_PASSWD=ENV['TWITTER_PASSWD']

class MashupController < ApplicationController

  def index
    if session[:hits]
      @hits, @all_hits = session[:hits]
    else
      friends_status =
        Twitter::Base.new(T_ACCOUNT, T_PASSWD).friends.collect { |friend|
          [friend.name, friend.status.text] if friend.status
        }.compact
      @hits = []
      @all_hits = []
      friends_status.each {|name, status|
        @all_hits << [name, status]
        Places::EntityExtraction.new(status).place_names.each {|place_name|
          @hits << [name, place_name, status]
          puts "** ** #{name}: #{place_name}"
        }
      }
      session[:hits] = [@hits, @all_hits]
    end
    @chosen_hit = @hits[rand(@hits.length)]
    if @chosen_hit
      results = Geocoding::get(@chosen_hit[1])
      pp results
      @map = GMap.new("map_div")
      @map.control_init(:small_map => true,:map_type => true)
      if results.length > 0
        @map.center_zoom_init([results[0].latitude,results[0].longitude],12)
        @map.overlay_init(GMarker.new([results[0].latitude,results[0].longitude],:title => "#{@chosen_hit[0]}: #{@chosen_hit[2]}", :info_window => "Info! Info!"))
        #@map.overlay_init(GMarker.new("Sedona Arizona",:info_window => "Sedona"))
      end
    end
  end

end
