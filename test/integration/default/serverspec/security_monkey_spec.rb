require 'spec_helper'

%w(
  python-dev
  python-psycopg2
  postgresql
  postgresql-contrib
  libpq-dev
).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

describe user('security_monkey') do
  it { should exist }
end

describe file('/opt/security_monkey/current/setup.py') do
  it { should be_file }
  it { should be_owned_by 'security_monkey' }
end

describe file('/opt/security_monkey/current/env-config/config-deploy.py') do
  it { should be_file }
  it { should be_owned_by 'security_monkey' }
  it { should contain 'LOG_LEVEL = "DEBUG"' }
  it { should contain "SECURITY_TEAM_EMAIL = 'securityteam@example.com'" }
end
