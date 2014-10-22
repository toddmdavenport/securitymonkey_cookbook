#
# Cookbook Name:: securitymonkey
# Recipe:: install
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
supervisor_path = "#{node['securitymonkey']['post_deploy_path']}/supervisor"
deploy_path = "#{node['securitymonkey']['post_deploy_path']}"

include_recipe "apt::default"
include_recipe 'build-essential::default'
include_recipe "git::default"
include_recipe "python::default"
include_recipe "postgresql::client"
include_recipe "supervisor"
include_recipe 'chef-sugar::default'

%w(
  python-psycopg2
  curl
  nginx
).each do |pkg|
  package pkg do
    action :install
  end
end

service "nginx" do
  action :nothing
end

user node['securitymonkey']['run_as'] do
  shell "/bin/bash"
  home "/home/#{node['securitymonkey']['run_as']}"
  supports :manage_home => true
  system true
  action :create
end

deploy_revision node['securitymonkey']['deploy_directory'] do
  user node['securitymonkey']['run_as']
  repository node['securitymonkey']['repo']
  branch node['securitymonkey']['branch']
  action node['securitymonkey']['force_deploy'] ? :force_deploy : :deploy
  symlinks({})
  symlink_before_migrate({})

  before_migrate do

    if node['securitymonkey']['password_salt'].nil? ||
      node['securitymonkey']['secret_key'].nil?
      raise "You must provide a value for the attributes password_salt and secret_key"
    end

    template "#{release_path}/env-config/config-deploy.py" do
      source "config-deploy.py.erb"
      mode 0700
      variables(
        :log_level => node['securitymonkey']['log_level'],
        :email => node['securitymonkey']['security_team_email'],
        :fqdn => node['securitymonkey']['fqdn'] || node['fqdn'],
        :password_salt => node['securitymonkey']['password_salt'],
        :secret_key => node['securitymonkey']['secret_key'],
        :db_uri => node['securitymonkey']['db']['uri']
      )
    end
  end

  before_symlink do
    execute "run-setup" do
      command 'python setup.py install'
      cwd release_path
    end

    execute "flask-migrate" do
       environment({ 'SECURITY_MONKEY_SETTINGS' => "#{release_path}/env-config/config-deploy.py" })
       command 'python manage.py db upgrade'
       cwd release_path
    end
  end

  action :deploy
end

ssl_certificate "securitymonkey" do
  key_path node['securitymonkey']['ssl_key_path']
  cert_path node['securitymonkey']['ssl_cert_path']
  common_name node['securitymonkey']['fqdn']
  only_if { vagrant? }
end

file "/var/log/nginx/securitymonkey.access.log" do
  owner "www-data"
  group "adm"
  action :create_if_missing
end

file "/var/log/nginx/securitymonkey.error.log" do
  owner "www-data"
  group "adm"
  action :create_if_missing
end

template "/etc/nginx/sites-available/securitymonkey.conf" do
  source "nginx-securitymonkey.conf.erb"
  mode 0644
  user 'www-data'
  variables(
    :ssl_key_path => node['securitymonkey']['ssl_key_path'],
    :use_ssl => node['securitymonkey']['use_ssl'],
    :ssl_cert_path => node['securitymonkey']['ssl_cert_path'],
    :release_path => deploy_path
)
  action :create
  notifies :create, "link[/etc/nginx/sites-enabled/securitymonkey.conf]", :immediately
  notifies :restart, 'service[nginx]', :delayed
end

link "/etc/nginx/sites-enabled/securitymonkey.conf" do
  to "/etc/nginx/sites-available/securitymonkey.conf"
  action :nothing
end

supervisor_service "securitymonkey" do
  command "python #{deploy_path}/manage.py run_api_server"
  user "root"
  environment :SECURITY_MONKEY_SETTINGS=>"#{deploy_path}/env-config/config-deploy.py" 
  action [:enable, :start]
end

supervisor_service "securitymonkeyscheduler" do
  command "python #{deploy_path}/manage.py start_scheduler"
  environment :PYTHONPATH=> deploy_path,
              :SECURITY_MONKEY_SETTINGS=>"#{deploy_path}/env-config/config-deploy.py" 
  user "root"
  autostart true
  autorestart true
  action [:enable, :start]
  not_if { vagrant? }
end
