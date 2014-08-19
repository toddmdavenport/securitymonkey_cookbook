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

  before_migrate do
    template "#{release_path}/env-config/config-deploy.py" do
      source "config-deploy.py.erb"
      mode 0700
      variables(
        :log_level => node['securitymonkey']['log_level'],
        :email => node['securitymonkey']['security_team_email'],
        :fqdn => node['fqdn']
      )
    end
  end

  before_symlink do
    execute "run-setup" do
      command  'python setup.py install'
      cwd release_path
    end

    # execute "flask-migrate" do
    #   environment({ 'SECURITY_MONKEY_SETTINGS' => "#{release_path}/env-config/config-deploy.py" })
    #   command 'python manage.py db upgrade'
    #   cwd release_path
    # end
  end

  action :deploy
end






