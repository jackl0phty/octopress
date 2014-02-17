# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails/tree/master/assets
#   https://github.com/capistrano/rails/tree/master/migrations
#
# require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
# require 'capistrano/bundler'
# require 'capistrano/rails/assets'
# require 'capistrano/rails/migrations'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }

### Setup deploy for octopress task.###

# Set app name.
set :application, "octopress"

# git repo to clone.
set :scm, :git
set :repository, "git@github.com:jackl0phty/octopress.git"
set :scm_passphrase, ""

# Set Capistrano deploy user.
set :user, "yoda"

# Set app description.
desc "Deploy Octopress to staging."

task :octopress do
  on "pi01.home" do
    execute "ls -al /tmp"
  end
end
