require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina/whenever'
require 'mina/npm'


# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :rails_env, 'production'
set :application_name, 'farm'
set :domain, 'farm-do'
set :user, fetch(:application_name)
set :deploy_to, "/home/#{fetch(:user)}/app"
set :repository, 'https://github.com/jarvisjohnson/farm-r.git'
set :branch, 'master'
set :rvm_use_path, '/etc/profile.d/rvm.sh'
set :app_root,   '/Users/swish/Dev/farm-r'   # Local path to application
# Require github user and pass to deploy: https://github.com/mina-deploy/mina/issues/99
set :execution_mode, :system

# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
set :shared_dirs, fetch(:shared_dirs, []).push('public/system')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml', 'config/config.yml', 'config/schedule.rb')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  ruby_version = File.read('.ruby-version').strip
  raise "Couldn't determine Ruby version: Do you have a file .ruby-version in your project root?" if ruby_version.empty?
  
  # The script file used by git to establish the ssh connection  
  # queue! %[export GIT_SSH="#{file_to('clone.sh')}"]

  invoke :'rvm:use', ruby_version
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do

  in_path(fetch(:shared_path)) do

    command %[mkdir -p config]

    # Create database.yml for Postgres if it doesn't exist
    path_database_yml = "config/database.yml"
    database_yml = %[default: &default
      adapter: mysql2
      encoding: utf8

    production:
      <<: *default
      database: #{fetch(:user)}
      username: #{fetch(:user)}
      password: #{fetch(:user)}
      host: 127.0.0.1
      port: 3306]
    command %[test -e #{path_database_yml} || echo "#{database_yml}" > #{path_database_yml}]

    # Create secrets.yml if it doesn't exist
    path_secrets_yml = "config/secrets.yml"
    secrets_yml = %[production:\n  secret_key_base:\n    #{`rake secret`.strip}]
    command %[test -e #{path_secrets_yml} || echo "#{secrets_yml}" > #{path_secrets_yml}]
    
    # Create config.yml if it doesn't exist    
    path_secrets_yml = "config/config.yml"
    secrets_yml = %[production:]
    command %[test -e #{path_secrets_yml} || echo "#{secrets_yml}" > #{path_secrets_yml}]

    # Remove others-permission for config directory
    command %[chmod -R o-rwx config]
  end

end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'npm:install'    
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'
    invoke :'whenever:update'    

    on launch: :environment do
      command "sudo service #{fetch(:user)} restart"
      # command %{mkdir -p tmp/}
      # command %{touch tmp/restart.txt}
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

task :delayed_jobs => :environment do
  command "cd #{fetch(:deploy_to)}/current ; RAILS_ENV=production bundle exec rake ts:index ; RAILS_ENV=production bundle exec rake ts:restart ; RAILS_ENV=production bin/delayed_job restart"  
end

task :start_search => :environment do
  command "cd #{fetch(:deploy_to)}/current ; RAILS_ENV=production bundle exec rake ts:start"  
end

task :stop_jobs => :environment do
  command "cd #{fetch(:deploy_to)}/current ; RAILS_ENV=production bin/delayed_job start"  
end

task :logs do
  command "tail -f #{fetch(:deploy_to)}/shared/log/*"  
end

task :restart do
  command "sudo service #{fetch(:user)} restart"
end

task :console => :environment do
  command "cd #{fetch(:deploy_to)}/current ; RAILS_ENV=production rails console"
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
