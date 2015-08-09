
if ENV['RACK_ENV'] == 'production'
  require 'grape'
  require 'skylight'
  Skylight.start!(file: 'config/skylight.yml')
end
