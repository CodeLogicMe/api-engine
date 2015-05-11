require 'grape'

require_relative './helpers'
require_relative './middlewares/janus'
require_relative './middlewares/terminus'
require_relative './middlewares/veritas'
require_rel './resources/*.rb'

class Engine < Grape::API
  version 'v1', using: :header, vendor: 'restinme'
  format :json
  content_type :json, 'application/json'

  use Middlewares::Janus
  use Middlewares::Terminus
  use Middlewares::Veritas

  helpers ::AuthHelpers

  mount ::Resources::Authentication
  mount ::Resources::Endpoints
end
