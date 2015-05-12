source 'https://rubygems.org'

gem 'grape', '~> 0.11'
gem 'sinatra', require: false # just because cloud66 needs it
gem 'mongoid', '4.0.0'
gem 'bcrypt', '~> 3.1'
gem 'rack-cors', '~> 0.4'
gem 'require_all', '~> 1.3'

# in memory database & enqueueing
gem 'redis'
gem 'redis-namespace'

# background workers
gem 'sidekiq'

# request analysis
gem 'geocoder'

group :development, :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'factory_girl', '~> 4.4.0'
  gem 'faker'
  gem 'database_cleaner'
  gem 'pry'
  gem 'did_you_mean'
end

group :development do
  gem 'foreman'
  gem 'executable-hooks'
  gem 'rerun'
  gem 'rb-fsevent'
end
