require 'grape'

require_relative './helpers'
require_relative './middlewares/janus'
require_relative './middlewares/veritas'
require_rel './resources/*.rb'
require_relative './rate_limiter'

class Engine < Grape::API
  version 'v1', using: :header, vendor: 'restinme'
  format :json
  content_type :json, 'application/json'

  use Middlewares::Janus
  use Middlewares::Veritas

  helpers ::AuthHelpers

  mount ::Resources::Authentication
  mount ::Resources::Endpoints
end
