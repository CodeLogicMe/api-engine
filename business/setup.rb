module Authk
  Models = Module.new
  Actions = Module.new
  Extensions = Module.new
  Resources = Module.new
end

require_relative './extensions'
require_relative './models'
require_relative './actions'
