# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_wikipedia_name_finder_web_app_session',
  :secret      => 'b3d2ffe3f7b514ff82616fb25b55c885d6629e11cad6f6cfe72c14e15ef9458bb8826132fc936f029994ac9237097d2b9de1884865405e4815cdbeff57074531'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
