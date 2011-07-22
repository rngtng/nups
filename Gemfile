source 'http://rubygems.org'

gem 'rails', '3.1.0.rc4'
gem 'mysql2'

gem 'jquery-rails'

gem 'haml'
gem 'sass'

#Authorization
gem 'devise'

# Use resque for async jobs
gem 'resque'
#gem 'resque-scheduler'

#For handling File uploads
gem 'paperclip'

#For proper pagination
gem 'kaminari'

# For excel export
gem 'ekuseru'

# parsing bounce emails
gem 'rngtng-bounce-email', '0.1.0'

gem 'state_machine'

gem 'nokogiri'
gem 'premailer'

group :production do
  gem 'therubyracer'
end

group :development do
  gem 'coffee-script'
  gem 'uglifier'

  # Deploy with Capistrano
  gem 'capistrano'
  gem 'mailcatcher'
  gem 'ruby-graphviz', :require => 'graphviz'
  gem "rspec-rails", "~> 2.6.1.beta1"
end

group :test do
  gem 'rspec-rails', "~> 2.6.1.beta1"
  gem 'resque_spec'
  gem 'delorean'
  gem 'watchr'
end
