app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/../../shared/"
dev_env = !File.exists?(File.join(app_dir, 'RAILS_ENV'))
log_path = (dev_env ? "#{app_dir}/" : shared_dir) + "log"
pid_file = (dev_env ? "#{app_dir}/tmp/" : shared_dir) + 'pids/unicorn.pid'

working_directory app_dir
worker_processes (dev_env ? 1 : 2)
preload_app true
timeout 60
listen 3000
pid pid_file
stderr_path "#{log_path}/unicorn.stderr.log"
stdout_path "#{log_path}/unicorn.stdout.log"