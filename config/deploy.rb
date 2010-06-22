set :application, "nups"

set :use_sudo, false

#it's rails 3 baby, so make sure rvm setup is used!
rvm_path = '/kunden/warteschlange.de/.rvm'
ruby_v   = "ruby-1.9.2-head"
set :default_environment, { 
  'PATH' => "#{rvm_path}/rubies/#{ruby_v}/bin:#{rvm_path}/gems/#{ruby_v}/bin:#{rvm_path}/bin:$PATH",
  'RUBY_VERSION' => ruby_v,
  'GEM_HOME'     => "#{rvm_path}/gems/#{ruby_v}",
  'GEM_PATH'     => "#{rvm_path}/gems/#{ruby_v}",
  'BUNDLE_PATH'  => "#{rvm_path}/gems/#{ruby_v}"  # If you are using bundler.
}

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/kunden/warteschlange.de/produktiv/rails/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :repository, "git://github.com/rngtng/nups.git"
set :branch, "master"
set :deploy_via, :remote_cache

set :user, 'ssh-21560'
set :ssh_options, { :forward_agent => true }

role :app, "nups.warteschlange.de"
role :web, "nups.warteschlange.de"
role :db,  "nups.warteschlange.de", :primary => true
role :job, "nups.warteschlange.de"

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Link in the production database.yml" 
  task :link_configs do
    run "ln -nfs #{deploy_to}/#{shared_dir}/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/#{shared_dir}/mail.yml #{release_path}/config/mail.yml"
  end  
  
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

## Rails 3 updates:  http://rand9.com/blog/bundler-0-9-1-with-capistrano
namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
  
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test"
  end
  
  task :lock, :roles => :app do
    run "cd #{current_release} && bundle lock;"
  end
  
  task :unlock, :roles => :app do
    run "cd #{current_release} && bundle unlock;"
  end
end

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

namespace :resque do
  resque_pid = File.join(current_release,"tmp/pids/resque_worker.pid")
  resque_log = "log/resque_worker.log"
  
  desc "start all resque workers"
  task :start, :roles => :job do    
    unless remote_file_exists?(resque_pid)
      run "cd #{current_release}; RAILS_ENV=production QUEUE=* VERBOSE=1 nohup rake resque:work &> #{resque_log}& 2> /dev/null && echo $! > #{resque_pid}"
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



# HOOKS
after "deploy:update_code" do
  bundler.bundle_new_release
  deploy.link_configs
end
