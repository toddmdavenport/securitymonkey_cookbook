#
# Cookbook Name:: securitymonkey
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt::default"
include_recipe "git::default"
include_recipe "python::default"

%w(
  python-dev
  python-psycopg2
  postgresql
  postgresql-contrib
  libpq-dev
).each do |pkg|
  package pkg do
    action :install
  end
end

user node['securitymonkey']['run_as'] do
  shell "/bin/bash"
  system true
  action :create
end

deploy_revision node['securitymonkey']['deploy_directory'] do
  user "security_monkey"
  repository node['securitymonkey']['repo']
  branch node['securitymonkey']['branch']
  symlinks({})
  symlink_before_migrate({})
  action :deploy
  %w(execute[run-setup]).each do |item|
    notifies :run, item
  end
end

template "/opt/security_monkey/current/env-config/config-deploy.py" do
  source "config-deploy.py.erb"
  mode 0700
  variables(
    :log_level => node['securitymonkey']['log_level'],
    :email => node['securitymonkey']['security_team_email']
  )
end

execute "run-setup" do
  command  'python setup.py install'
  cwd "#{node['securitymonkey']['deploy_directory']}/current"
  action :nothing
end
