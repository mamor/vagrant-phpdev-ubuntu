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
	command 'apt-get upgrade -y'
end

#
# install php and apache
#
%w{php5 php5-mysqlnd}.each do |p|
	package p do
		action :install
	end
end

execute 'a2enmod' do
	command 'a2enmod rewrite'
end

service 'apache2' do
	supports :status => true, :restart => true, :reload => true
	action [:enable, :reload]
end

#
# install mysql
#
package 'mysql-server' do
	action :install
	notifies :run, 'execute[mysqladmin]'
end

execute 'mysqladmin' do
	action :nothing
	command 'mysqladmin password -u root ' + node['mysql']['password']
end

#
# install packages by apt-get
#
%w{mongodb redis-server phpmyadmin}.each do |p|
	package p do
		action :install
	end
end

execute 'git' do
	command '
		git config --global user.email "' + node['git']['user']['email'] + '"
		git config --global user.name "' + node['git']['user']['name'] + '"
	'
end
 
link '/var/www/phpmyadmin' do
	to '/usr/share/phpmyadmin'
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

%w{coffee-script}.each do |p|
	execute p do
		command 'npm install -g ' + p
	end
end

rbenv_ruby '2.0.0-p247' do
	action :install
end

rbenv_global '2.0.0-p247' do
end

#
# install packages by gem
#
%w{fluentd jsduck serverspec}.each do |p|
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

=begin
rbenv_script 'passenger' do
	code <<-CODE
		dd if=/dev/zero of=/swap bs=1M count=1024;
		mkswap /swap;
		swapon /swap;
		passenger-install-apache2-module --auto;
		swapoff /swap;
	CODE
	not_if {File.exists?('/usr/local/rbenv/versions/2.0.0-p247/lib/ruby/gems/2.0.0/gems/passenger-4.0.10/buildout/apache2/mod_passenger.so')}
end
=end

package 'libmysqlclient-dev' do
	action :install
end

%w{rails mysql2}.each do |p|
	rbenv_gem p do
		action :install
	end
end

#
# templates
#
template '/etc/php5/apache2/php.ini' do
	notifies :reload, 'service[apache2]'
end

template '/etc/php5/cli/php.ini' do
end

template '/etc/apache2/sites-available/default' do
	notifies :reload, 'service[apache2]'
end

#
# run custom recipe
#
begin
	include_recipe 'phpdev::custom'
rescue Exception => error
	# avoid Chef::Exceptions::RecipeNotFound
end
