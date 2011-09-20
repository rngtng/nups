require 'rubygems'

require 'yaml' #for travis
YAML::ENGINE.yamler= 'syck' #for travis

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
