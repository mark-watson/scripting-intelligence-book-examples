# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rails_http_headers_session',
  :secret      => '7687718771642092a9181a84ed9dce4f5a9cccf79c26ce7499c1484b591944ba09974bd6d59eed6681c09e3aea93e9e81060932899fdc437bfc3c437916493ae'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
