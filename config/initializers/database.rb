require 'grape/activerecord'
require 'active_record'
require 'pg'

Grape::ActiveRecord.database_file = 'config/db/sql.yml'
ActiveRecord::Migrator.migrations_paths += ['config/db/migrations']
