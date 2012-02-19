# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_interesting_things_web_app_session',
  :secret      => 'b91f119433e4941b36b680a5696eb819235131ee848ccf52e42b49f84fa440302c5c88c3fc91abb3422325b95dc9e34fb7f87b1e46429051580c38a286ab8dc9'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
