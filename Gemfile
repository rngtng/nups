source 'http://rubygems.org'

#gem 'rails', :git => 'git://github.com/rails/rails.git', :branch => '3-1-stable'
gem 'rails', '3.1.0.rc4'

gem 'mysql2'

gem 'jquery-rails'

gem 'haml'
gem 'sass'

#Authorization
gem 'devise'

# Use resque for async jobs
gem 'resque'
gem 'resque-scheduler', '2.0.0.d'

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

group :development do
  # gem 'coffee-rails', '3.1.0.rc4'
  # gem 'coffee-script'
  # gem 'uglifier'

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
