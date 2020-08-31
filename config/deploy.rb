require "rvm/capistrano"
require "bundler/capistrano"
require 'whenever/capistrano'

default_run_options[:pty] = true
#ssh_options[:forward_agent] = true

set :application, "timetracker"
set :repository, "https://github.com/nascenia/timetracker.git"

set :scm, :git
set :deploy_via, :remote_cache
set :branch, "development"
set :keep_releases, 10

set :user, "deployer"

set :use_sudo, false

set :rvm_ruby_string, 'ruby-2.1.1'
set :rvm_type, :system
set :rake, 'bundle exec rake'

set :bundle_cmd, "bundle"
set :rake, 'bundle exec rake'

after('deploy:update_code', 'deploy:symlink_shared', 'deploy:migrate')

task :staging do
  set :branch, "new_employee_reg_production"
  web_server = "timetracker.test.nascenia.com"
  role :web, web_server # Your HTTP server, Apache/etc
  role :app, web_server # This may be the same as your `Web` server
  role :db, web_server, :primary => true # This is where Rails migrations will run
  set :deploy_to, "/www/apps/#{application}/"
  set :delayed_job_id, 2
  set :whenever_identifier, defer { "#{application}-staging" }
  set :whenever_command, 'bundle exec whenever'
end

task :prod do
  set :branch, "new_emp_prod"
  web_server = "timetracker.nascenia.com"
  role :web, web_server # Your HTTP server, Apache/etc
  role :app, web_server # This may be the same as your `Web` server
  role :db, web_server, :primary => true # This is where Rails migrations will run
  set :deploy_to, "/www/apps/#{application}-staging/"
  set :rails_env, "staging"
  set :delayed_job_id, 2
  set :whenever_identifier, defer { "#{application}-prod" }
  set :whenever_command, 'bundle exec whenever'
end

namespace :deploy do

  desc "Tell Passenger to restart the app."
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
    run "ln -nfs #{shared_path}/config/mailer_conf.yml #{release_path}/config/mailer_conf.yml"
    run "ln -nfs #{shared_path}/system #{release_path}/public/system"
    run "ln -nfs #{shared_path}/public/uploads  #{release_path}/public/uploads"
  end

  task :create_shared_files_and_directories, :role => :app do
    run "mkdir -p #{shared_path}/sockets"
    run "mkdir -p #{shared_path}/config/.bundle"
    #run "mkdir -p #{shared_path}/bundle"
    #run "touch #{shared_path}/config/.bundle/config"

    #run "echo '---' >> #{shared_path}/config/.bundle/config"
    #run "echo 'BUNDLE_PATH: vendor/bundle' >> #{shared_path}/config/.bundle/config"
    #run "echo \"BUNDLE_DISABLE_SHARED_GEMS: '1'\" >> #{shared_path}/config/.bundle/config"
  end

  namespace :web do
    desc <<-DESC
      Present a maintenance page to visitors. Disables your application's web \
      interface by writing a "maintenance.html" file to each web server. The \
      servers must be configured to detect the presence of this file, and if \
      it is present, always display it instead of performing the request.

      By default, the maintenance page will just say the site is down for \
      "maintenance", and will be back "shortly", but you can customize the \
      page by specifying the REASON and UNTIL environment variables:
        $ cap deploy:web:disable \\
              REASON="a hardware upgrade" \\
              UNTIL="12pm Central Time"

      Further customization will require that you write your own task.
    DESC
    task :disable, :roles => :web do
      require 'erb'
      on_rollback { run "rm #{shared_path}/system/maintenance.html" }

      reason = ENV['REASON']
      deadline = ENV['UNTIL']
      template = File.read('app/views/layouts/maintenance.html.erb')
      page = ERB.new(template).result(binding)
      put page, "#{shared_path}/system/maintenance.html", :mode => 0644
      puts "In /opt/nginx/conf/nginx.conf file enable/write the lines below."
      puts "if (-f $document_root/system/maintenance.html) {\n
        rewrite ^(.*)$ /system/maintenance.html break;      \n
      }"
    end

    task :enable, :roles => :web do
      run "rm #{shared_path}/system/maintenance.html"
      puts "In /opt/nginx/conf/nginx.conf file comment out/remove the lines below."
      puts "if (-f $document_root/system/maintenance.html) {\n
        rewrite ^(.*)$ /system/maintenance.html break;      \n
      }"
    end
  end

  task :create_shared_files_and_directories, :roles => :web do
    if rails_env == 'production'

    end
  end

end

after "deploy:setup", :"deploy:create_shared_files_and_directories"
