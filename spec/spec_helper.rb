require 'simplecov'
SimpleCov.start 'rails' if ENV["COV"]

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'

# https://github.com/jnicklas/capybara
# http://jumpstartlab.com/resources/testing-ruby/integration-testing-with-rspec-capybara-and-selenium/
# http://opinionatedprogrammer.com/2011/02/capybara-and-selenium-with-rspec-and-rails-3/
# http://railscasts.com/episodes/257-request-specs-and-capybara?view=asciicast
# http://jfire.posterous.com/selenium-on-ruby
# http://seleniumhq.wordpress.com/
# Load Capybara integration
require 'capybara/rspec'
require 'capybara/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include Delorean
  config.include FactoryGirl::Syntax::Methods

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using Active Record or Active Record fixtures
  config.fixture_path = "#{::Rails.root.to_s}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false #true

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    #DatabaseCleaner.clean_with(:truncation)
  end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
