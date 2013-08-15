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
apt_repository 'php5' do
	uri 'http://ppa.launchpad.net/ondrej/php5/ubuntu'
	distribution node['lsb']['codename']
	components ['main']
	keyserver 'keyserver.ubuntu.com'
	key 'E5267A6C'
end

apt_repository 'apache2' do
	uri 'http://ppa.launchpad.net/ondrej/apache2/ubuntu'
	distribution node['lsb']['codename']
	components ['main']
	keyserver 'keyserver.ubuntu.com'
	key 'E5267A6C'
end

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
%w{git mongodb redis-server phpmyadmin}.each do |p|
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

%w{coffee-script grunt-cli}.each do |p|
	execute p do
		command 'npm install -g ' + p
	end
end

#
# install packages by gem
#
%w{fluentd jsduck serverspec compass}.each do |p|
	gem_package p do
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

template '/etc/apache2/apache2.conf' do
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
