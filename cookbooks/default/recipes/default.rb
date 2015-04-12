# encoding: utf-8

#
# Cookbook Name:: default
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#
# ufw (firewall) config
#
execute 'ufw-enable' do
  command 'ufw default deny; printf y | ufw enable'
end

node['ufw']['allows'].each do |allow|
  execute 'ufw-allow-' + allow do
    command 'ufw allow ' + allow
  end
end

execute 'ufw-reload' do
  command "ufw reload"
end

#
# ssh config
#
service 'ssh' do
  # @see https://github.com/opscode-cookbooks/openssh/pull/30/files
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

template '/etc/ssh/sshd_config' do
  source 'ssh/sshd_config.erb'
  notifies :reload, 'service[ssh]'
end

#
# locale and timezone
#
execute 'locale' do
  command "locale-gen #{node['locale']}; update-locale LANGUAGE=#{node['locale']} LC_ALL=#{node['locale']} LANG=#{node['locale']}  2> /dev/null"
end

execute 'timezone' do
  command "echo '#{node['timezone']}' > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata"
end

#
# set .bashrc and hosts by templates, set hostname
#
template "/home/vagrant/.bashrc" do
  source 'default/.bashrc.erb'
  user 'vagrant'
  group 'vagrant'
end

template '/etc/hosts' do
  source 'default/hosts.erb'
end

execute 'hostname' do
  command "hostname #{node['server']}"
end

#
# install packages
#
%w{zip}.each do |p|
  package p do
    action :install
  end
end

#
# install git
#
package 'git' do
  action :install
end

execute 'git-config-user-email' do
  user 'vagrant'
  group 'vagrant'
  environment ({'HOME' => '/home/vagrant'})
  command "git config --global user.email '#{node['git']['user']['email']}'"
end

execute 'git-config-user-name' do
  user 'vagrant'
  group 'vagrant'
  environment ({'HOME' => '/home/vagrant'})
  command "git config --global user.name '#{node['git']['user']['name']}'"
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

%w{php5 php5-dev php5-curl php5-mcrypt php5-gd}.each do |p|
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

template '/etc/php5/apache2/php.ini' do
  source 'php/php.ini.erb'
  notifies :restart, 'service[apache2]'
end

template '/etc/php5/cli/php.ini' do
  source 'php/php.ini.erb'
end

template '/etc/apache2/apache2.conf' do
  source 'apache/apache2.conf.erb'
  notifies :restart, 'service[apache2]'
end

template '/etc/apache2/sites-available/000-default.conf' do
  source 'apache/000-default.conf.erb'
  notifies :restart, 'service[apache2]'
end

#
# install composer
#
composer '/usr/local/bin' do
  action :install
end

#
# install mysql
#
package 'mysql-server' do
  action :install
  notifies :run, 'execute[mysqladmin]', :immediately
end

service 'mysql' do
  # @see service[ssh]
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

execute 'mysqladmin' do
  action :nothing
  command 'mysqladmin password -u root ' + node['mysql']['root']['password']
end

package 'php5-mysqlnd' do
  action :install
end

template '/etc/mysql/my.cnf' do
  source 'mysql/my.cnf.erb'
  notifies :restart, 'service[mysql]'
end

#
# install mongodb
#
package 'mongodb' do
  action :install
end

service 'mongodb' do
  # @see service[ssh]
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

execute 'pecl-mongo' do
  command 'pecl install mongo'
  creates '/usr/lib/php5/20121212/mongo.so'
end

#
# install td-agent
#
execute 'td-agent' do
  command 'curl -L http://toolbelt.treasure-data.com/sh/install-ubuntu-precise.sh | sh'
  creates '/etc/init.d/td-agent'
  notifies :run, 'execute[fluent-plugin-mysqlslowquery]'
end

group 'adm' do
  action :modify
  members ['td-agent']
  append true
end

execute 'fluent-plugin-mysqlslowquery' do
  action :nothing
  command '/usr/lib/fluent/ruby/bin/fluent-gem install fluent-plugin-mysqlslowquery'
end

service 'td-agent' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

template '/etc/td-agent/td-agent.conf' do
  source 'default/td-agent.conf.erb'
  notifies :restart, 'service[td-agent]'
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

%w{yo gulp grunt-cli karma bower}.each do |p|
  execute p do
    command 'npm install -g ' + p
    not_if "npm -g ls 2> /dev/null | grep '^[├└]─[─┬] #{p}@'"
  end
end

#
# install packages by gem
#
%w{compass}.each do |p|
  gem_package p do
    action :install
  end
end

#
# install redis
#
package 'redis-server' do
  action :install
end

service 'redis-server' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

#
# install postfix
#
package 'mailutils' do
  action :install
end

service 'postfix' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

template '/etc/mailname' do
  source 'postfix/mailname.erb'
  notifies :restart, 'service[postfix]'
end

template '/etc/postfix/header_checks' do
  source 'postfix/header_checks.erb'
  notifies :restart, 'service[postfix]'
end

template '/etc/postfix/main.cf' do
  source 'postfix/main.cf.erb'
  notifies :restart, 'service[postfix]'
end
