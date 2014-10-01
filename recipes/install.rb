#
# Cookbook Name:: securitymonkey
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt::default"
include_recipe 'build-essential::default'
include_recipe "git::default"
include_recipe "python::default"
include_recipe "postgresql::client"

%w(
  python-psycopg2
  nginx
  supervisor
).each do |pkg|
  package pkg do
    action :install
  end
end

user node['securitymonkey']['run_as'] do
  shell "/bin/bash"
  home "/home/#{node['securitymonkey']['run_as']}"
  supports :manage_home => true
  system true
  action :create
end

deploy_revision node['securitymonkey']['deploy_directory'] do
  user "security_monkey"
  repository node['securitymonkey']['repo']
  branch node['securitymonkey']['branch']

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
        :fqdn => node['fqdn'],
        :password_salt => node['securitymonkey']['password_salt'],
        :secret_key => node['securitymonkey']['secret_key']
      )
    end
  end

  before_symlink do
    execute "run-setup" do
      command  'python setup.py install'
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

service "nginx" do
  action :nothing
end

ssl_certificate "security_monkey" do
  key_path node['security_monkey']['ssl_key_path']
  cert_path node['security_monkey']['ssl_cert_path']
  common_name node['security_monkey']['fqdn']
end

directory "/var/log/nginx/log" do
  owner "www-data"
  group "adm"
  mode "0644"
  action :create
end

file "/etc/nginx/sites-enabled/default" do
  action :delete
end

file "/var/log/nginx/log/securitymonkey.access.log" do
  owner "www-data"
  group "adm"
  # mode "0644"
  action :create_if_missing
end

file "/var/log/nginx/log/securitymonkey.error.log" do
  owner "www-data"
  group "adm"
  # mode "0644"
  action :create_if_missing
end

template "/etc/nginx/sites-available/securitymonkey.conf" do
  source "nginx-securitymonkey.conf.erb"
  mode 0644
  variables(
    :ssl_key_path => node['security_monkey']['ssl_key_path'],
    :ssl_cert_path => node['security_monkey']['ssl_cert_path'],
    :release_path => node['securitymonkey']['post_deploy_path']
  )
  action :create
  user 'www-data'
  notifies :restart, 'service[nginx]', :immediately
end

link "/etc/nginx/sites-enabled/securitymonkey.conf" do
  to "/etc/nginx/sites-available/securitymonkey.conf"
end

supervisor_path = "#{node['securitymonkey']['post_deploy_path']}/supervisor"

service "supervisor" do
  action :stop
end

template "#{supervisor_path}/security_monkey.ini" do
  source "secuity-monkey-supervisor.ini.erb"
  mode 0644
  variables(
    :user => node['securitymonkey']['run_as'],
    :release_path => "#{node['securitymonkey']['post_deploy_path']}"
  )
  action :create
  user 'security_monkey'
end

execute "supervisord -c security_monkey.ini" do
  cwd supervisor_path
  user 'root'
  not_if "pgrep supervisord"
  notifies :run, "execute[supervisorctl -c security_monkey.ini]", :immediately
end

execute "supervisorctl -c security_monkey.ini" do
  cwd supervisor_path
  user 'root'
  action :nothing
end

