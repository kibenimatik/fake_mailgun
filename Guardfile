guard 'bundler' do
  watch('Gemfile')
end

guard 'rack' do
  watch('Gemfile.lock')
  watch(%r{^(config|app|api)/.*})
end

guard 'sidekiq', :require => './sidekiq_helper.rb' do
  watch('app/callbacks.rb')
end
