securitymonkey Cookbook
=======================

Installs and configures the SecurityMonkey from Netflix.

Requirements
------------
Only tested on Ubuntu 14.04

Usage
-----
#### securitymonkey::database

Used to install a local (and insecure) postgresql database for testing. In production an AWS RDS postgresql instance is recomended. 

#### securitymonkey::install

Include `securitymonkey` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[securitymonkey::install]"
  ]
}
```

Attributes
----------
#### securitymonkey::default

|Key                                        |Type   |Description    |Default    |
|-------------------------------------------|-------|---------------|-----------|
|['securitymonkey']['run_as']               |String |system user should own the service, application code and config |security_monkey |
|['securitymonkey']['deploy_directory']     |String |path to deploy the application code when fetched from the repository |/opt/security_monkey |
|['securitymonkey']['repo']                 |String |Repository hosting the application |https://github.com/Netflix/security_monkey.git |
|['securitymonkey']['branch']               |String |git branch from the repository |master | 
|['securitymonkey']['log_level']            |String |DEBUG, INFO, WARN, ERROR |WARN |
|['securitymonkey']['db']['username']       |String |Postgres user |security_monkey |
|['securitymonkey']['db']['password']       |String |Postgres pass |sec_mky_password |
|['securitymonkey']['security_team_email']  |String |where Security Monkey sends alerts |securityteam@example.com |
|['securitymonkey']['secret_key']|          |String |session key for flask user sessions |nil |
|['securitymonkey']['password_salt']        |String |salt for bcrypt password storage |nil |
|['securitymonkey']['use_ssl']              |Bool   |should nginx server content over ssl |true |
|['securitymonkey']['ssl_key_path']         |String |where the ssl secret key should be stored |etc/ssl/private/securitymonkey.key |
|['securitymonkey']['ssl_cert_path']        |String |where the ssl certificate should be stored |/etc/ssl/certs/securitymonkey.pem |
|['securitymonkey']['fqdn']                 |String |fully qulified domain name of the host |default-ubuntu-1404.vagrantup.com |
|['nginx']['default_site_enabled']          |Bool   |Should nginx's 'default' site be enabled |false |
|['supervisor']['dir']                      |String |Where should supervisord manage config files |/etc/supervisor/conf.d |


Contributing
------------

1. Fork the repository on Github
1. Set-up your Vagrant environment [http://berkshelf.com/#install-vagrant](http://berkshelf.com/#install-vagrant) and run tests with
    ```shell
    $ bundle
    $ bundle exec berks install
    $ bundle exec kitchen test
    ```

1. Create a named feature branch (like `add_component_x`)
1. Write your change
1. Write tests for your change (if applicable)
1. Run the tests, ensuring they all pass
1. Submit a Pull Request using Github

License
-------

MIT

Authors
-------
Authors: Travis Truman - trumant@gmail.com
