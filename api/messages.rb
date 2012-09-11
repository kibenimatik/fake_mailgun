module Mailgun
  class Messages < Grape::API
    version 'v2', :using => :path, :vendor => 'mailgun', :format => :json
    rescue_from :all do |e|
      Rack::Response.new([ e.message ], 500, { 'Content-type' => 'text/error' }).finish
    end

    resource :messages do
      desc 'Returns logs'
      get do
        $LOG
      end

      desc 'Sends message'
      post do
        $LOG << params
        Callbacks.perform_async params
        { message:'Queued. Thank you.', id:'<20120203170704.20654.39224@samples.mailgun.org>'}
      end
    end
  end
end
