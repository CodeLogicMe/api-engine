require 'sinatra'

module Authentik
  class Frontend < Sinatra::Base
    get '/' do
      'Hello World!'
    end
  end
end
