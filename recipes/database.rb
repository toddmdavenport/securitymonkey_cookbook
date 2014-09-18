# create a postgresql database with additional parameters
include_recipe "database::postgresql"

%w(
  python-psycopg2
  postgresql
  postgresql-contrib
  libpq-dev
  postgresql-server-dev-all
).each do |pkg|
  package pkg do
    action :install
  end
end

#chef_gem "pg" do
#  action :install
#end

postgresql_database 'secmon' do
 connection(
   :host     => '127.0.0.1',
   :port     => 5432,
   :username => 'postgres',
   :password => 'password'
 )
 template 'DEFAULT'
 encoding 'DEFAULT'
 tablespace 'DEFAULT'
 connection_limit '-1'
 owner 'postgres'
 action :create
end