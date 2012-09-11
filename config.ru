require File.expand_path('../config/environment', __FILE__)

run Mailgun::App.new

