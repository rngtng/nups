## TAKEN from: https://gist.github.com/797301
require 'resque/tasks'
require 'resque_scheduler/tasks'

# Start a worker with proper env vars and output redirection
def run_worker(queue, count = 1)
  puts "Starting #{count} worker(s) with QUEUE: #{queue}"
  ops = {:pgroup => true, :err => [(Rails.root + "log/resque_err").to_s, "a"],
                          :out => [(Rails.root + "log/resque_stdout").to_s, "a"]}
  env_vars = {"QUEUE" => queue.to_s}
  count.times {
    ## Using Kernel.spawn and Process.detach because regular system() call would
    ## cause the processes to quit when capistrano finishes
    pid = spawn(env_vars, "rake resque:work", ops)
    Process.detach(pid)
  }
end

namespace :resque do
  task :setup => :environment do
    require 'resque'
    require 'resque_scheduler'
    require 'resque/scheduler'

    resque_config = YAML.load_file(Rails.root + '/config/resque.yml')
    # you probably already have this somewhere
    Resque.redis = resque_config[rails_env]

    # The schedule doesn't need to be stored in a YAML, it just needs to
    # be a hash.  YAML is usually the easiest.
    Resque.schedule = YAML.load_file('your_resque_schedule.yml')

    # If your schedule already has +queue+ set for each job, you don't
    # need to require your jobs.  This can be an advantage since it's
    # less code that resque-scheduler needs to know about. But in a small
    # project, it's usually easier to just include you job classes here.
    # So, someting like this:
    require 'jobs'

    # If you want to be able to dynamically change the schedule,
    # uncomment this line.  A dynamic schedule can be updated via the
    # Resque::Scheduler.set_schedule (and remove_schedule) methods.
    # When dynamic is set to true, the scheduler process looks for
    # schedule changes and applies them on the fly.
    # Note: This feature is only available in >=2.0.0.
    #Resque::Scheduler.dynamic = true
  end

  desc "Restart running workers"
  task :restart_workers => :environment do
    Rake::Task['resque:stop_workers'].invoke
    Rake::Task['resque:start_workers'].invoke
  end

  desc "Quit running workers"
  task :stop_workers => :environment do
    pids = Array.new
    Resque.workers.each do |worker|
      pids.concat(worker.worker_pids)
    end
    if pids.empty?
      puts "No workers to kill"
    else
      syscmd = "kill -s QUIT #{pids.join(' ')}"
      puts "Running syscmd: #{syscmd}"
      system(syscmd)
    end
  end

  desc "Start workers"
  task :start_workers => :environment do
    run_worker(Newsletter::QUEUE, 1)
    run_worker(SendOut::QUEUE, 2)
  end
end