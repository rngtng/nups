source 'http://rubygems.org'

#gem 'rails', :git => 'git://github.com/rails/rails.git', :branch => '3-1-stable'
gem 'rails', '~> 3.1.0'

gem 'mysql2'

gem 'jquery-rails'

gem 'haml'

#Authorization
gem "devise", "~> 1.4.3"

# Use resque for async jobs
gem 'resque'
gem 'resque-scheduler', '~> 2.0.0.d'

#For handling File uploads
gem 'paperclip'

#For proper pagination
gem 'kaminari'

# For excel export
gem 'ekuseru'

# parsing bounce emails
gem 'rngtng-bounce-email', '~> 0.1.0'

gem 'state_machine'

gem 'nokogiri'
gem 'premailer'

group :development do
  # Deploy with Capistrano
  gem 'capistrano'
  gem 'mailcatcher'
  gem 'ruby-graphviz', :require => 'graphviz'
  gem 'rspec-rails', '~> 2.6.1'
end

# http://metaskills.net/2011/07/29/use-compass-sass-framework-files-with-the-rails-3.1.0.rc5-asset-pipeline/
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  # gem 'compass', :git => 'git://github.com/chriseppstein/compass.git', :branch => 'rails31'
end

group :test do
  gem 'rspec-rails', '~> 2.6.1'
  gem 'resque_spec'
  gem 'delorean'
  gem 'watchr'
  gem 'json' #needed for resque to run on travis-ci
end
