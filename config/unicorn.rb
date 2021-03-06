app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/../../shared/"
dev_env = !File.exists?(File.join(app_dir, 'RAILS_ENV'))
use_default_directories = dev_env
log_path = (use_default_directories ? "#{app_dir}/" : shared_dir) + "log"
pid_file = (use_default_directories ? "#{app_dir}/tmp/" : shared_dir) + 'pids/unicorn.pid'

working_directory app_dir
worker_processes (dev_env ? 1 : 2)
preload_app true
listen 3000
pid pid_file
timeout (dev_env ? 6000 : 60)

unless dev_env
  
  # if logs aren't displayed inline, pry cannot work.
  stderr_path "#{log_path}/unicorn.stderr.log"
  stdout_path "#{log_path}/unicorn.stdout.log"
  
end

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end