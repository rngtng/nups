## TAKEN from: https://gist.github.com/797301
require 'resque/tasks'
require 'resque_scheduler/tasks'

namespace :resque do
  task :setup => :environment do
    require 'resque'
    require 'resque_scheduler'
    require 'resque/scheduler'

    resque_config = YAML.load_file (Rails.root + 'config/resque.yml').to_s
    # you probably already have this somewhere
    Resque.redis = resque_config[Rails.env]

    # The schedule doesn't need to be stored in a YAML, it just needs to
    # be a hash.  YAML is usually the easiest.
    Resque.schedule = YAML.load_file (Rails.root + 'config/resque_schedule.yml').to_s

    # If your schedule already has +queue+ set for each job, you don't
    # need to require your jobs.  This can be an advantage since it's
    # less code that resque-scheduler needs to know about. But in a small
    # project, it's usually easier to just include you job classes here.
    # So, someting like this:
    #require 'jobs'

    # If you want to be able to dynamically change the schedule,
    # uncomment this line.  A dynamic schedule can be updated via the
    # Resque::Scheduler.set_schedule (and remove_schedule) methods.
    # When dynamic is set to true, the scheduler process looks for
    # schedule changes and applies them on the fly.
    # Note: This feature is only available in >=2.0.0.
    Resque::Scheduler.dynamic = true
  end

  desc "Restart running workers"
  task :restart_workers => :environment do
    Rake::Task['resque:stop_workers'].invoke
    Rake::Task['resque:start_workers'].invoke
  end

  desc "Quit running workers"
  task :stop_workers => :environment do
    pids = Resque.workers.select do |worker|
      worker.to_s.include?('nups2_')
    end.map(&:worker_pids).flatten.uniq

    if pids.any?
      syscmd = "kill -s QUIT #{pids.join(' ')}"
      puts "Running syscmd: #{syscmd}"
      system(syscmd)
    else
      puts "No workers to kill"
    end
  end

  # http://stackoverflow.com/questions/2532427/why-is-rake-not-able-to-invoke-multiple-tasks-consecutively
  desc "Start workers"
  task :start_workers => :environment do
    Rake::Task['resque:start_worker'].execute(:queue => Bounce, :count => 1, :jobs => 100)
    Rake::Task['resque:start_worker'].execute(:queue => Newsletter)
    Rake::Task['resque:start_worker'].execute(:queue => SendOut, :count => 10, :jobs => 100)
  end

  # http://nhw.pl/wp/2008/10/11/rake-and-arguments-for-tasks
  desc "Start a worker with proper env vars and output redirection"
  task :start_worker, [:queue, :count, :jobs] => :environment do |t, args|
    args = args.to_hash.reverse_merge(:count => 1, :jobs => 1)
    queue = args[:queue].to_s.underscore.classify.constantize::QUEUE

    puts "Starting #{args[:count]} worker(s) with #{args[:jobs]} Jobs for QUEUE: #{queue}"
    ops = {:pgroup => true, :err => [(Rails.root + "log/resque_err").to_s, "a"],
                            :out => [(Rails.root + "log/resque_stdout").to_s, "a"]}
    env_vars = {"QUEUE" => queue.to_s, "JOBS_PER_FORK" => args[:jobs].to_s}
    args[:count].times {
      ## Using Kernel.spawn and Process.detach because regular system() call would
      ## cause the processes to quit when capistrano finishes
      pid = spawn(env_vars, "rake resque:work", ops)
      Process.detach(pid)
    }
  end
end