name             'securitymonkey'
maintainer       'Travis Truman'
maintainer_email 'trumant@gmail.com'
license          'MIT'

description      'Installs/Configures securitymonkey'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "apt"
depends "build-essential", ">= 1.4.2"
depends "git"
depends "python"
depends "postgresql"
depends "supervisor"
depends "ssl_certificate"
recomends "database"
