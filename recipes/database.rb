# create a postgresql database with additional parameters
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