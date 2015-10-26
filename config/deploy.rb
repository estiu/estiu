# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'events'
set :repo_url, 'git@bitbucket.org:vemv/events.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '~/events'

# Default value for :format is :pretty
# set :format, :pretty

set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# remove --quiet flag, replace it for --verbose. Doesn't seem to work. Whatever.
# remove --deployment flag, so system gems (fetched with Packer) are used instead of installed again.
# This allows instantiating production-ready images real quick.
set :bundle_flags, '--verbose'
set :bundle_path, nil # use system gems

set :rbenv_ruby, '2.2.3'

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
