require 'yaml'
config = YAML.load_file(File.join(__dir__, '../db/sql.yml'))

require 'grape/activerecord'
require 'active_record'
require 'pg'

Grape::ActiveRecord.database = config.fetch(ENV['RACK_ENV'])
ActiveRecord::Migrator.migrations_paths += ["config/db/migrations"]
