Models = Module.new
Actions = Module.new
Extensions = Module.new
Resources = Module.new
Engines = Module.new
Services = Module.new
Workers = Module.new
Contexts = Module.new

require_relative './extensions'
require_rel './engines/*.rb'
require_rel './models/*.rb'
require_rel './actions/*.rb'
require_rel './contexts/*.rb'
require_rel './services/*.rb'
require_rel './workers/*.rb'
