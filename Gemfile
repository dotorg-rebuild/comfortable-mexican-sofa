source 'http://rubygems.org'

gemspec
gem 'rails', '4.1.1'
gem 'ransack'

group :development do
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
end

group :test do
  gem 'sqlite3',                          :platform => [:ruby, :mswin, :mingw]
  gem 'jdbc-sqlite3',                     :platform => :jruby
  gem 'activerecord-jdbcsqlite3-adapter', :platform => :jruby
  gem 'mocha',      :require => false
  gem 'coveralls',  :require => false

  gem 'rspec'
  gem 'rspec-rails'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'ffaker'
  gem 'timecop'
  gem 'pry'
  gem 'pry-nav'
end
