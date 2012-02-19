T_ACCOUNT=ENV['TWITTER_ACCOUNT']
T_PASSWD=ENV['TWITTER_PASSWD']

require 'twitter'
require 'pp'

#pp (Twitter::Base.new(T_ACCOUNT, T_PASSWD).public_methods - Object.public_methods).sort

#pp Twitter::Base.new(T_ACCOUNT, T_PASSWD)

#pp Twitter::Base.new(T_ACCOUNT, T_PASSWD).user('mark_l_watson')

#my_status = Twitter::Base.new(T_ACCOUNT, T_PASSWD).status('mark_l_watson')
#puts "my_status = #{my_status}"

def update_my_status status
  Twitter::Base.new(T_ACCOUNT, T_PASSWD).update(status)
end

#update_my_status('Gone hiking with my brother')

def get_friends_status
	Twitter::Base.new(T_ACCOUNT, T_PASSWD).friends.collect { |friend|
	  [friend.name, friend.status.text] if friend.status
	}.compact
end

pp get_friends_status

