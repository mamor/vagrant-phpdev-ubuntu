# encoding: utf-8

require 'spec_helper'

#
# ufw (firewall) config
#
%w{80 22}.each do |port|
  describe port(port) do
    it { should be_listening }
  end
end

#
# ssh config
#
describe service('ssh') do
  it { should be_enabled }
  it { should be_running }
end

#
# locale and timezone
#
describe file('/etc/default/locale') do
  %w{LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8}.each do |line|
    it { should contain line }
  end
end

describe file('/etc/timezone') do
  its(:content) { should match /Asia\/Tokyo/ }
end

#
# set .bashrc and hosts by templates, set hostname
#
describe command('hostname') do
  its(:stdout) { should eq "phpdev\n" }
end

#
# install packages
#
%w{zip}.each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

#
# install git
#
describe package('git') do
  it { should be_installed }
end

describe command('git config --global user.email') do
  its(:stdout) { should eq "vagrant@phpdev\n" }
end

describe command('git config --global user.name') do
  its(:stdout) { should eq "vagrant\n" }
end

#
# install php and apache
#
%w{php5 php5-dev php5-curl php5-mcrypt php5-gd}.each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe service('apache2') do
  it { should be_enabled }
  it { should be_running }
end

describe command('a2enmod rewrite') do
  its(:stdout) { should eq "Module rewrite already enabled\n" }
end

#
# install composer
#
describe file('/usr/local/bin/composer') do
  it { should be_executable }
end

#
# install mysql
#
%w{mysql-server php5-mysqlnd}.each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe service('mysql') do
  it { should be_enabled }
  it { should be_running }
end

describe command('mysql -u root') do
  its(:exit_status) { should eq 1 }
end

#
# install mongodb
#
describe package('mongodb') do
  it { should be_installed }
end

describe service('mongodb') do
  it { should be_enabled }
  it { should be_running }
end

describe command('php -r "phpinfo();" | grep mongo') do
  its(:exit_status) { should eq 0 }
end

#
# install td-agent
#
describe file('/etc/init.d/td-agent') do
  it { should be_executable }
end

describe command('groups td-agent') do
  its(:stdout) { should eq "td-agent : td-agent adm\n" }
end

describe command('/usr/lib/fluent/ruby/bin/fluent-gem list | grep fluent-plugin-mysqlslowquery') do
  its(:exit_status) { should eq 0 }
end

describe service('td-agent') do
  it { should be_enabled }
  it { should be_running }
end

#
# install packages by npm
#
describe package('nodejs') do
  it { should be_installed }
end

%w{yo gulp grunt-cli karma bower}.each do |p|
  describe command("npm -g ls 2> /dev/null | grep '^[├└]─[─┬] #{p}@'") do
    its(:exit_status) { should eq 0 }
  end
end

#
# install packages by gem
#
%w{compass}.each do |p|
  describe command('gem list | grep ' + p) do
    its(:exit_status) { should eq 0 }
  end
end

#
# install redis
#
describe package('redis-server') do
  it { should be_installed }
end

describe service('redis-server') do
  it { should be_enabled }
  it { should be_running }
end

#
# install postfix
#
describe package('mailutils') do
  it { should be_installed }
end

describe service('postfix') do
  it { should be_enabled }
  it { should be_running }
end
