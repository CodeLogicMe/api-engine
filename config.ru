require File.expand_path('../config/application', __FILE__)

require './api/server'
require './frontend/server'

class SubdomainDispatcher
  def initialize
    @api      = Authentik::API.new
    @frontend = Authentik::Frontend.new
  end

  def call(env)
    api?(env) ? @api.call(env) : @frontend.call(env)
  end

  private

  def api?(env)
    !!/^\/?api/.match(env['REQUEST_PATH'])
  end
end

run SubdomainDispatcher.new
