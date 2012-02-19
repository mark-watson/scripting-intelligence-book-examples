# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mashup_web_app_session',
  :secret      => '2f77b028b04e4c9f329b3ae3a3f672ba6a9d33590218ea62b69a04479fa1c4d3374884fbea564985fadc17d806b6fdda2123eadffa9db52f99847a2545790ce1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
