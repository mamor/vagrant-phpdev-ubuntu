# PHP Development on Vagrant

## Features

* PHP 5.4 http://php.net/
* Apache 2.2 http://www.apache.org/
* MySQL 5.5 http://www.mysql.com/
* phpMyAdmin http://www.phpmyadmin.net/ http://localhost:8080/phpmyadmin/ (root/root)
* DBDocs https://github.com/mp-php/fuel-dbdocs http://localhost:8080/dbdocs/
* PHPUnit http://phpunit.de/manual/
* ApiGen http://apigen.org/
* PHP-CS-Fixer http://cs.sensiolabs.org/
* jsduck https://github.com/senchalabs/jsduck
* node.js http://nodejs.org/
* CoffeeScript http://coffeescript.org/
* Fluentd http://fluentd.org/
* MongoDB http://www.mongodb.org/
* Redis http://redis.io/
* serverspec http://serverspec.org/
* Phusion Passenger https://www.phusionpassenger.com/
* Ruby on Rails http://rubyonrails.org/

## Usage

### Run

	$ git clone --recursive https://github.com/mp-php/vagrant-phpdev-ubuntu.git
	$ cd vagrant-phpdev-ubuntu/
	$ vagrant up # Please wait a few minutes

### Make Project

#### On your machine

	$ mkdir share/my_first_project
	$ vim share/my_first_project/index.php

##### share/my_first_project/index.php

	<?php
	phpinfo();

##### Log in with vagrant ssh

	$ vagrant ssh

#### On vagrant

	$ sudo ln -s /share/my_first_project /var/www/my_first_project

access http://localhost:8080/my_first_project/

## Customize

	$ cp cookbooks/phpdev/recipes/custom.rb.default cookbooks/phpdev/recipes/custom.rb

edit cookbooks/phpdev/recipes/custom.rb

## License

Copyright 2013, Mamoru Otsuka. Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
