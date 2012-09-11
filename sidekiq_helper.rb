require 'sidekiq'

# If your client is single-threaded, we just need a single connection in our Redis connection pool
Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'x', :size => 1, :url => 'redis://127.0.0.1:6379/10' }
end

root_path = File.dirname(__FILE__)
require "#{root_path}/app/callbacks.rb"

