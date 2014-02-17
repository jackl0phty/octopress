set :stage, :octopress_stage

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
#role :app, %w{deploy@example.com}
#role :web, %w{deploy@example.com}
#role :db,  %w{deploy@example.com}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# something that quacks like a hash can be used to set
# extended properties on the server.
#server 'example.com', user: 'deploy', roles: %w{web app}, my_property: :my_value

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
# and/or per server
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# setting per server overrides global ssh_options

# fetch(:default_env).merge!(rails_env: :octopress_stage)

# Setup deploy to staging task.
#server 'pi.home'
#desc 'Deploy Octopress to staging.'
#task :deploy_octopress_stage do
#  run 'dig google.com'
#end

# Set this forward agent option to not have to add your server's ssh public key to your repository's host authorized keys
#set :ssh_options, { :forward_agent => true }

#require "bundler/capistrano"

set :keep_releases, 5
set :scm, :git
set :scm_verbose, false

# Set your repository URL
#set :repository, 'git@github.com:jackl0phty/octopress.git'

# Set your application name
#set :application, "jackl0phty_toolbox"

# Set branch to clone.
#set :branch, "master"

# Don't do full clone on every checkout.
#set :deploy_via, :remote_cache

# Set your machine user
#set :user, 'yoda'

#set :deploy_to, "/tmp/octopress"
#set :use_sudo, false

# Set your host, you can use the server IPs here if you don't have one yet
#role :app, 'pi.home', :primary => true

#default_run_options[:pty] = true

# Generate latest version of octopress blog.
#task :generate do
#  run_locally do
#    generate_output = `rake generate`
#    puts "#{generate_output}"
#  end
#end

# Preview latest version of octopress blog.
#task :preview do
#  run_locally do
#    preview_output = `rake preview`
#    puts "#{preview_output}"
#  end
#end

# Deploy octopress blog via Rsync.
task :rsync_deploy do
  run_locally do
    preview_output = `dig google.com`
    puts "#{preview_output}"
  end
end

#after 'deploy:update_code', 'deploy:cleanup'
#after 'bundle:install', 'octopress:generate'

