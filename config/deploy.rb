
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

require 'rvm/capistrano'
require 'bundler/capistrano'
require 'new_relic/recipes'

set :application, "nups"
set :host, "www2.warteschlange.de"

set :use_sudo, false
set :user, 'ssh-21560'

set :rvm_type, :user
set :rvm_ruby_string, "ruby-1.9.2-p290"

set :keep_releases, 3

set :default_environment, {
  'LANG' => 'en_US.UTF-8'
}

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/kunden/warteschlange.de/produktiv/rails/#{application}2"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :repository, "git://github.com/rngtng/#{application}.git"
set :branch, "delivery"

set :normalize_asset_timestamps, false

set :deploy_via, :remote_cache

set :ssh_options, :forward_agent => true

role :app, host
role :web, host
role :db,  host, :primary => true
role :job, host

##
# Rake helper task.
# http://pastie.org/255489
# http://geminstallthat.wordpress.com/2008/01/27/rake-tasks-through-capistrano/
# http://ananelson.com/said/on/2007/12/30/remote-rake-tasks-with-capistrano/
def run_remote_rake(rake_cmd)
  rake_args = ENV['RAKE_ARGS'].to_s.split(',')
  cmd = "cd #{fetch(:latest_release)} && #{fetch(:rake, "rake")} RAILS_ENV=#{fetch(:rails_env, "production")} #{rake_cmd}"
  cmd += "['#{rake_args.join("','")}']" unless rake_args.empty?
  run cmd
  set :rakefile, nil if exists?(:rakefile)
end


namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Link in the production database.yml"
  task :link_configs do
    run "ln -nfs #{deploy_to}/#{shared_dir}/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/#{shared_dir}/mail.yml #{release_path}/config/mail.yml"
    run "ln -nfs #{deploy_to}/#{shared_dir}/uploads #{release_path}/public/system"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  desc "Restart Resque Workers"
  task :restart_workers, :roles => :job do
    run_remote_rake "resque:restart_workers"
    resque.scheduler.stop
    resque.scheduler.start
  end

  desc "precompile the assets"
  task :precompile_assets, :roles => :web, :except => { :no_release => true } do
    run_remote_rake "assets:precompile"
  end
end

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

namespace :resque do
  namespace :scheduler do
    def scheduler_pid
      File.join(current_release, "tmp/pids/resque_scheduler.pid")
    end

    def scheduler_log
      File.join(current_release, "log/resque_scheduler.log")
    end

    desc "start scheduler"
    task :start, :roles => :job do
      unless remote_file_exists?(scheduler_pid)
        # INITIALIZER_PATH=#{current_release}/
        run "cd #{current_release}; RAILS_ENV=production PIDFILE=#{scheduler_pid} nohup bundle exec rake resque:scheduler &> #{scheduler_log}& 2> /dev/null"
      else
        puts "PID File exits!!"
      end
    end

    desc "stop scheduler"
    task :stop, :roles => :job do
      if remote_file_exists?(scheduler_pid)
        begin
          run "kill -s QUIT `cat #{scheduler_pid}`"
        rescue
        end
        run "rm -f #{scheduler_pid}"
      else
        puts "No PID File found"
      end
    end
  end
end

after "deploy:update_code" do
  deploy.link_configs
  deploy.precompile_assets
end

after "deploy:symlink", "deploy:restart_workers"
after "deploy:symlink", "deploy:cleanup"
after "deploy:update", "newrelic:notice_deployment"
#        require './config/boot'
#        require 'airbrake/capistrano'

