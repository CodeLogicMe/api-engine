module RestInMe
  Models = Module.new
  Actions = Module.new
  Extensions = Module.new
  Resources = Module.new
  Engines = Module.new
end

require_relative './extensions'
require_relative './actions'
require_rel './engines/*.rb'
require_rel './models/*.rb'
