module Mailgun
  class Campaigns < Grape::API
    version 'v2', :using => :path, :vendor => 'mailgun', :format => :json
    rescue_from :all do |e|
      Rack::Response.new([ e.message ], 500, { 'Content-type' => 'text/error' }).finish
    end

    resource :campaigns do
      desc 'Creates a new campaign under a given domain. '
      post do
        $LOG << params
        { message:'Created campaign. Thank you.'}
      end
    end
  end
end
