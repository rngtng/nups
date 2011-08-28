require 'yaml'
require 'resque'
require 'resque_scheduler'

resque_config = YAML.load_file (Rails.root + 'config/resque.yml').to_s
Resque.redis = resque_config[Rails.env]
Resque::Scheduler.dynamic = true