# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rails_rdfa_session',
  :secret      => '996edd2991991c8d635024acb5d9ae52a4ace9216b614eff6a9b034bb58f506a918a3be1b682dab1c09dc24b510297966e625749146e852e83fd50ac74f6d804'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
