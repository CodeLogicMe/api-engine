Models = Module.new
Actions = Module.new
Extensions = Module.new
Resources = Module.new
Engines = Module.new

require_relative './extensions'
require_rel './engines/*.rb'
require_rel './models/*.rb'
require_rel './actions/*.rb'
