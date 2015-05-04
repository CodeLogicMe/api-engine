require 'grape'

require_relative './helpers'
require_rel './resources/*.rb'

class Engine < Grape::API
  version 'v1', using: :header, vendor: 'restinme'
  format :json
  content_type :json, 'application/json'

  helpers ::AuthHelpers

  mount ::Resources::Authentication
  mount ::Resources::Endpoints
end
