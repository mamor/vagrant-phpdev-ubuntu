#
# Cookbook Name:: phpdev
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#
# initialize
#
template '/home/vagrant/.bashrc' do
  user 'vagrant'
  group 'vagrant'
end

execute 'apt-get' do
  command 'apt-get update'
end

#
# install php and apache
#
%w{php5 php5-dev php-pear php5-mysqlnd}.each do |p|
  package p do
    action :install
  end
end

service 'apache2' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

execute 'a2enmod' do
  command 'a2enmod rewrite' # apache will be restarted by template
end

#
# install mysql
#
package 'mysql-server' do
  action :install
  notifies :run, 'execute[mysqladmin]'
  notifies :run, 'execute[mysql]'
end

service 'mysql' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

execute 'mysqladmin' do
  action :nothing
  command 'mysqladmin password -u root ' + node['mysql']['password']
end

execute 'mysql' do
  action :nothing
  command "mysql -u root -p#{node['mysql']['password']} -e \"GRANT ALL PRIVILEGES ON *.* TO root@'%' IDENTIFIED BY '#{node['mysql']['password']}' WITH GRANT OPTION\""
end

#
# install packages by apt-get
#
%w{mongodb redis-server phpmyadmin}.each do |p|
  package p do
    action :install
  end
end

service 'mongodb' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

service 'redis-server' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

link '/var/www/phpmyadmin' do
  to '/usr/share/phpmyadmin'
end

#
# git settings
#
execute 'git-config-user-email' do
  command "sudo -u vagrant -H git config --global user.email \"#{node['git']['user']['email']}\""
end

execute 'git-config-user-name' do
  command "sudo -u vagrant -H git config --global user.name \"#{node['git']['user']['name']}\""
end

#
# install packages by pecl
#
execute 'pecl-mongo' do
  command 'pecl install mongo'
  not_if {File.exists?('/usr/lib/php5/20100525/mongo.so')}
end

#
# install packages by npm
#
apt_repository 'nodejs' do
  uri 'http://ppa.launchpad.net/chris-lea/node.js/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key 'C7917B12'
end

package 'nodejs' do
  action :install
end

%w{coffee-script jshint grunt-cli}.each do |p|
  execute p do
    command 'npm install -g ' + p
  end
end

#
# install packages by gem
#
rbenv_ruby '2.0.0-p247' do
  action :install
end

rbenv_global '2.0.0-p247' do
end

%w{fluentd jsduck serverspec compass heroku}.each do |p|
  rbenv_gem p do
    action :install
  end
end

#
# install passenger and rails
#
rbenv_gem 'passenger' do
  action :install
  version '4.0.10'
end

%w{libcurl4-openssl-dev apache2-threaded-dev libapr1-dev libaprutil1-dev}.each do |p|
  package p do
    action :install
  end
end

rbenv_script 'passenger' do
  code <<-CMD
    dd if=/dev/zero of=/swap bs=1M count=1024
    mkswap /swap
    swapon /swap
    passenger-install-apache2-module -a
    swapoff /swap
  CMD
  not_if {File.exists?('/usr/local/rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/passenger-4.0.10/buildout/apache2/mod_passenger.so')}
end

template '/etc/apache2/conf.d/passenger.conf' do
  notifies :restart, 'service[apache2]'
end

package 'libmysqlclient-dev' do
  action :install
end

%w{rails mysql2}.each do |p|
  rbenv_gem p do
    action :install
  end
end

#
# install PhantomJS
#
execute 'phantomjs' do
  command <<-CMD
    wget https://phantomjs.googlecode.com/files/phantomjs-1.9.1-linux-x86_64.tar.bz2
    tar jxvf phantomjs-1.9.1-linux-x86_64.tar.bz2
    cp phantomjs-1.9.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs
    rm -r phantomjs-1.9.1-linux-x86_64
    rm phantomjs-1.9.1-linux-x86_64.tar.bz2
  CMD
  not_if {File.exists?('/usr/local/bin/phantomjs')}
end

#
# templates
#
template '/etc/php5/apache2/php.ini' do
  notifies :restart, 'service[apache2]'
end

template '/etc/php5/cli/php.ini' do
end

template '/etc/apache2/sites-available/default' do
  notifies :restart, 'service[apache2]'
end

template '/etc/mysql/my.cnf' do
  notifies :restart, 'service[mysql]'
end

#
# run custom recipe
#
begin
  include_recipe 'phpdev::custom'
rescue Exception => error
  # avoid Chef::Exceptions::RecipeNotFound
end
