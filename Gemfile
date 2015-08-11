source 'https://rubygems.org'

# servers
gem 'grape', '~> 0.13'
gem 'sinatra', require: false # just because cloud66 needs it
gem 'rack-cors', '~> 0.4'

# database
gem 'grape-activerecord', git: 'git@github.com:CodeLogicMe/grape-activerecord.git'
gem 'activerecord'
gem 'pg'

# because I'm lazy
gem 'require_all', '~> 1.3'
gem 'closed_struct'

# encription
gem 'bcrypt', '~> 3.1'

# in memory database & enqueueing
gem 'hiredis', '~> 0.6.0'
gem 'redis'
gem 'redis-namespace'

# background workers
gem 'sidekiq'

# request analysis
gem 'geocoder'
gem 'browser'

# Monitoring
gem 'skylight', '~> 0.8.0.beta.3'

group :development, :test do
  gem 'rspec'
  gem 'pry'
  gem 'did_you_mean'
  gem 'dotenv-rails'
end

group :development do
  gem 'foreman'
  gem 'executable-hooks'
  gem 'rerun'
  gem 'rb-fsevent'
end

group :test do
  gem 'faker'
  gem 'database_cleaner'
  gem 'rack-test'
  gem 'factory_girl', '~> 4.4.0'
  gem 'timecop'
end
