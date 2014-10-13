require 'spec_helper'
require 'socket'

%w(
  python-dev
  python-psycopg2
).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

#tests for postgresql installed. Check to make sure that there is a secmon db in postgres

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
  it { should contain "SECURITY_TEAM_EMAIL = ['securityteam@example.com']" }
  it { should contain "FQDN = '#{Socket.gethostbyname(Socket.gethostname).first}'"}
  its(:content) { should match /^SECURITY_PASSWORD_SALT = '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'/ }
  its(:content) { should match /^SECRET_KEY = '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'/ }
end

describe file("/etc/ssl/private/securitymonkey.key") do
  it { should be_file }
  it { should be_owned_by 'root' }
end

describe file("/etc/ssl/certs/securitymonkey.pem") do
  it { should be_file }
  it { should be_owned_by 'root' }
end

describe file("/var/log/nginx/securitymonkey.access.log") do
  it { should be_file }
  it { should be_owned_by 'www-data' }
  it { should be_grouped_into 'adm' }
end

describe file("/var/log/nginx/securitymonkey.error.log") do 
  it { should be_file }
  it { should be_owned_by 'www-data' }
  it { should be_grouped_into 'adm' }
end

describe file "/etc/nginx/sites-available/securitymonkey.conf" do
  it { should be_file }
  it { should be_owned_by 'www-data' }
end

describe file("/etc/nginx/sites-enabled/securitymonkey.conf") do
  it { should be_linked_to "/etc/nginx/sites-available/securitymonkey.conf" }
end

describe service('supervisord') do
  it { should be_running }
end

describe service('nginx') do
  it { should be_running }
end

describe file('/opt/security_monkey/current/supervisor/security_monkey.ini') do
  it { should be_file }
  it { should be_owned_by 'security_monkey' }
end
