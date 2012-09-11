module Mailgun
  class API < Grape::API
    # prefix 'api'
    $LOG = []
    format :json
    mount ::Mailgun::Messages
    mount ::Mailgun::Campaigns
  end
end

