require 'grape/activerecord'
require 'active_record'
require 'pg'

if ENV['RACK_ENV'] == 'production'
  Grape::ActiveRecord.database_url = ENV['POSTGRESQL_URL_INT']
else
  Grape::ActiveRecord.database_file = 'config/db/sql.yml'
end
ActiveRecord::Migrator.migrations_paths += ['config/db/migrations']
