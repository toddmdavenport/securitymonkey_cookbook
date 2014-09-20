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
  supervisor
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
## TO-DO- Basic

supervisor_path = "#{node['securitymonkey']['deploy_directory']}/current/supervisor/"
#setup superisor http://securitymonkey.readthedocs.org/en/latest/quickstart1.html#setting-up-supervisor
  template "#{supervisor_path}/security_monkey.ini" do
    source "secuity-monkey-supervisor.ini.erb"
    mode 0644
    variables(
      :user => node['securitymonkey']['run_as'],
      :release_path => "#{node['securitymonkey']['deploy_directory']}/current"
    )
    action :create
    user 'security_monkey'
  end

execute "supervisord -c security_monkey.ini" do
  cwd supervisor_path
  user 'root'
  environment ({'HOME' => '/home/security_monkey'})
end

execute "supervisorctl -c security_monkey.ini" do
  cwd supervisor_path
  user 'root'
  environment ({'HOME' => '/home/security_monkey'})
end


# SSL cert #check other cookbooks to see how we setup ssl. Remember that this should be generic.


# nginx files


## TO-DO Extras
# facility to create secmon webapp users from cookbook

# create webapp rules from cookbook

