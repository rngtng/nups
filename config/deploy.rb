
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

require 'rvm/capistrano'
require 'bundler/capistrano'

set :application, "nups"

set :use_sudo, false
set :user, 'ssh-21560'

set :rvm_type, :user
set :rvm_ruby_string, "ruby-1.9.2-rc2@#{application}"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/kunden/warteschlange.de/produktiv/rails/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :repository, "git://github.com/rngtng/#{application}.git"
set :branch, "master"

set :deploy_via, :remote_cache

set :ssh_options, :forward_agent => true

role :app, "#{application}.warteschlange.de"
role :web, "#{application}.warteschlange.de"
role :db,  "#{application}.warteschlange.de", :primary => true
role :job, "#{application}.warteschlange.de"

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
end

namespace :resque do
  resque_pid = File.join(current_release,"tmp/pids/resque_worker.pid")
  resque_log = "log/resque_worker.log"

  desc "start all resque workers"
  task :start, :roles => :job do
    unless remote_file_exists?(resque_pid)
      run "cd #{release_path}; RAILS_ENV=production QUEUE=* VERBOSE=1 nohup rake resque:work &> #{resque_log}& 2> /dev/null && echo $! > #{resque_pid}"
    else
      puts "PID File exits!!"
    end
  end

  desc "stop all resque workers"
  task :stop, :roles => :job do
    if remote_file_exists?(resque_pid)
      begin
        run "kill -s QUIT `cat #{resque_pid}`"
      rescue
      end
      run "rm -f #{resque_pid}"
    else
      puts "No PID File found"
    end
  end

  desc "restart resque workers"
  task :restart, :roles => :job do
    resque.stop
    resque.start
  end
end

after "deploy:update_code" do
  deploy.link_configs
end

after "deploy:restart" do
  resque.restart
end
