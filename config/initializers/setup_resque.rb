require 'yaml'
require 'resque'
require 'resque_scheduler'

rails_root = Rails.root.to_s || File.dirname(__FILE__) + '/../..'
rails_env  = Rails.env || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')

Resque.redis = resque_config[rails_env]