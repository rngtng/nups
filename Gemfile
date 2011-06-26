source 'http://rubygems.org'

gem 'rails', '3.1.0.rc4'
gem 'mysql2'

gem 'sass'
gem 'coffee-script'
gem 'uglifier'

gem 'jquery-rails'

gem 'haml'

#Authorization
gem 'devise'

# Use resque for async jobs
gem 'resque'
#gem 'resque-scheduler'

#For handling File uploads
gem 'paperclip'

#For proper pagination
# gem 'will_paginate', '~> 3.0.pre2'

# For excel export
gem 'ekuseru'

# parsing bounce emails
gem 'rngtng-bounce-email', '0.1.0'

gem 'state_machine'

gem 'nokogiri'
gem 'premailer'

group :development do
  # Deploy with Capistrano
  gem 'capistrano'
  gem 'ruby-graphviz', :require => 'graphviz'
  gem "rspec-rails", "~> 2.6.1.beta1"
end

group :test do
  gem "rspec-rails", "~> 2.6.1.beta1"
  gem "resque_spec"
  gem "delorean"
end
