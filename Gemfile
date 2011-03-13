source 'http://rubygems.org'

gem 'rails', '3.0.5'
gem 'mysql2'

#Authorization
gem 'devise', '~> 1.1.2'

# Use resque for async jobs
gem 'resque'
#gem 'resque-scheduler'

#For handling File uploads
gem 'paperclip'

#for HTML textfield
gem 'tiny_mce'

#For proper pagination
gem 'will_paginate', '~> 3.0.pre2'

# For excel export
gem 'ekuseru'

# parsing bounce emails
gem 'rngtng-bounce-email', '0.1.0'

gem 'state_machine'

gem 'haml'

group :development do
  # Deploy with Capistrano
  gem 'capistrano'

  gem 'ruby-graphviz', :require => 'graphviz'
end

group :test, :development do
  gem "rspec-rails", "~> 2.4"
  gem "resque_spec"
  gem "delorean"
  #gem "resque_unit"
end
