name             'securitymonkey'
maintainer       'Travis Truman'
maintainer_email 'trumant@gmail.com'
license          'MIT'

description      'Installs/Configures securitymonkey'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "apt"
depends "build-essential"
depends "git"
depends "python"
depends "database"
depends "postgres"
depends "ssl_certificate"
depends "nginx"
depends "supervisor"
