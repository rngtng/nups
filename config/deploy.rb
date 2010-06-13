set :application, "nups"

set :use_sudo, false

#it's rails 3 baby, so make sure rvm setup is used!
p = '/kunden/warteschlange.de/.rvm/'
set :default_environment, { 
  'PATH' => "#{p}rubies/ruby-1.9.1-p378/bin:#{p}gems/ruby-1.9.1-p378/bin:#{p}bin:$PATH",
  'RUBY_VERSION' => 'ruby 1.9.1p378',
  'GEM_HOME'     => '/kunden/warteschlange.de/.rvm/gems/ruby-1.9.1-p378',
  'GEM_PATH'     => '/kunden/warteschlange.de/.rvm/gems/ruby-1.9.1-p378',
  'BUNDLE_PATH'  => '/kunden/warteschlange.de/.rvm/gems/ruby-1.9.1-p378'  # If you are using bundler.
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

namespace :resque do
  desc "start all resque workers with monit"
  task :start, :roles => :job do
    run "QUEUE=* rake resque:workers"
  end

  desc "stop all resque workers with monit"
  task :stop, :roles => :job do
    run ""
  end

  desc "restart all resque workers with monit"
  task :restart, :roles => :job do
    run "QUEUE=* rake resque:workers"
  end
end



# HOOKS
after "deploy:update_code" do
  bundler.bundle_new_release
  deploy.link_configs
end
