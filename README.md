securitymonkey Cookbook
=======================

Installs and configures the SecurityMonkey from Netflix.

Requirements
------------
Only tested on Ubuntu 14.04

Attributes
----------
#### securitymonkey::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['securitymonkey']['run_as']</tt></td>
    <td>String</td>
    <td>which system user should own the service, application code and config</td>
    <td><tt>security_monkey</tt></td>
  </tr>
  <tr>
    <td><tt>['securitymonkey']['deploy_directory']</tt></td>
    <td>String</td>
    <td>path to deploy the application code when fetched from the repository</td>
    <td><tt>/opt/security_monkey</tt></td>
  </tr>
  <tr>
    <td><tt>['securitymonkey']['repo']</tt></td>
    <td>String</td>
    <td>Repository hosting our application</td>
    <td><tt>https://github.com/Netflix/security_monkey.git</tt></td>
  </tr>
  <tr>
    <td><tt>['securitymonkey']['branch']</tt></td>
    <td>String</td>
    <td>Which branch do we want from the repository</td>
    <td><tt>master</tt></td>
  </tr>
  <tr>
    <td><tt>['securitymonkey']['log_level']</tt></td>
    <td>String</td>
    <td>DEBUG, INFO, WARN, ERROR</td>
    <td><tt>WARN</tt></td>
  </tr>
  <tr>
    <td><tt>['securitymonkey']['db']['username']</tt></td>
    <td>String</td>
    <td>Postgres user</td>
    <td><tt>security_monkey</tt></td>
  </tr>
  <tr>
    <td><tt>['securitymonkey']['db']['password']</tt></td>
    <td>String</td>
    <td>Postgres password</td>
    <td><tt>sec_mky_password</tt></td>
  </tr>
  <tr>
    <td><tt>['securitymonkey']['security_team_email']</tt></td>
    <td>String</td>
    <td>Where should Security Monkey send alerts?</td>
    <td><tt>securityteam@example.com</tt></td>
  </tr>
</table>

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
    "recipe[securitymonkey]"
  ]
}
```

Overide or set attributes to sensible

If you wish to handle ssl connections with and ELB you can set node['security_monkey']['use_ssl'] to false. Disabling ssl without handling it through other means is discoraged.


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
