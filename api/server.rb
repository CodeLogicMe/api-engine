require 'grape'
require 'rack/cors'

require_relative '../business/setup'
require_relative './engine'
require_relative './frontend'

class API < Grape::API
  format :json
  content_type :json, 'application/json'

  mount Engine => '/api'
  mount Frontend
end
