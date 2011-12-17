source 'http://rubygems.org'

gem 'rails', '~> 3.1.3'

gem 'mysql2'

gem 'jquery-rails'

gem 'haml'

#Authorization
gem "devise", "~> 1.5.0"

# Use resque for async jobs
gem 'resque'
gem 'resque-scheduler', '~> 2.0.0.e'
gem 'resque-jobs-per-fork'

#For handling File uploads
gem 'paperclip'

#For proper pagination
gem 'kaminari'

# For excel export
gem 'ekuseru'

# parsing bounce emails
gem 'bounce_email'

gem 'state_machine'

gem 'nokogiri'
gem 'premailer'

gem 'rpm_contrib'
gem 'newrelic_rpm'

gem 'airbrake'

# auto_link replacement
gem 'rinku'

group :development do
  gem 'rspec-rails' #for rake tasks
  gem 'capistrano'
  gem 'mailcatcher'
  gem 'ruby-graphviz', :require => 'graphviz'
end

# http://metaskills.net/2011/07/29/use-compass-sass-framework-files-with-the-rails-3.1.0.rc5-asset-pipeline/
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  # gem 'compass', :git => 'git://github.com/chriseppstein/compass.git', :branch => 'rails31'
end

group :test do
  gem 'rspec-rails'
  gem 'resque_spec'
  gem 'delorean'
  gem 'watchr'
  gem 'json' #needed for resque to run on travis-ci
  gem 'capybara' #selenium
  gem 'database_cleaner'
  gem 'simplecov'
  gem 'faker'
end
