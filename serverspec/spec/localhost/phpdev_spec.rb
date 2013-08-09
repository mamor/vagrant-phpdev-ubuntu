require 'spec_helper'

#
# install php and apache
#
%w{php5 apache2 php5-mysqlnd}.each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe command('a2enmod rewrite') do
  it { should return_stdout 'Module rewrite already enabled' }
end

describe service('apache2') do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end

describe file('/etc/php5/apache2/php.ini') do
  it { should be_file }
  it { should contain 'date.timezone = Asia/Tokyo' }
end

describe file('/etc/php5/cli/php.ini') do
  it { should be_file }
  it { should contain 'date.timezone = Asia/Tokyo' }
end

describe file('/etc/apache2/apache2.conf') do
  it { should be_file }
  it { should contain 'AllowOverride All' }
end

#
# install mysql
#
describe package('mysql-server') do
  it { should be_installed }
end

describe command('mysql -u root') do
  it { should return_stdout 'ERROR 1045 (28000): Access denied for user \'root\'@\'localhost\' (using password: NO)' }
end

#
# install packages by apt-get
#
%w{git mongodb redis-server phpmyadmin}.each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe file('/var/www/phpmyadmin') do
  it { should be_linked_to '/usr/share/phpmyadmin' }
end

#
# install packages by npm
#
describe package('nodejs') do
  it { should be_installed }
end

describe package('coffee-script') do
  it { should be_installed.by('npm') }
end

#
# install packages by gem
#
describe command('rbenv version') do
  it { should return_stdout /1\.9\.3-p448/ }
end

%w{fluentd jsduck}.each do |p|
  describe package(p) do
    it { should be_installed.by('gem') }
  end
end

#
# install composer
#
describe command('composer -V') do
  it { should return_stdout /Composer version/ }
end

#
# install phpdev-tools
#
describe file('/home/vagrant/phpdev-tools/.git') do
  it { should be_directory }
  it { should be_owned_by 'vagrant' }
  it { should be_grouped_into 'vagrant' }
end

describe file('/home/vagrant/fuel-dbdocs/composer.lock') do
  it { should be_file }
end

describe file('/usr/local/bin/phpunit') do
  it { should be_linked_to '/home/vagrant/phpdev-tools/vendor/bin/phpunit' }
end

describe file('/usr/local/bin/apigen') do
  it { should be_linked_to '/home/vagrant/phpdev-tools/vendor/bin/apigen.php' }
end

describe file('/usr/local/bin/php-cs-fixer') do
  it { should be_linked_to '/home/vagrant/phpdev-tools/vendor/bin/php-cs-fixer' }
end

#
# install fuel-dbdocs
#
describe file('/home/vagrant/fuel-dbdocs/.git') do
  it { should be_directory }
  it { should be_owned_by 'vagrant' }
  it { should be_grouped_into 'vagrant' }
end

describe file('/home/vagrant/fuel-dbdocs/fuel/packages/dbdocs/composer.lock') do
  it { should be_file }
end

describe file('/home/vagrant/fuel-dbdocs/fuel/app/config/crypt.php') do
  it { should be_file }
  it { should be_owned_by 'vagrant' }
  it { should be_grouped_into 'vagrant' }
end

describe file('/home/vagrant/fuel-dbdocs/fuel/app/logs') do
  it { should be_directory }
  it { should be_mode 777 }
end

describe file('/home/vagrant/fuel-dbdocs/public/dbdocs') do
  it { should be_directory }
  it { should be_mode 777 }
end

describe file('/var/www/dbdocs') do
  it { should be_linked_to '/home/vagrant/fuel-dbdocs/public' }
end

