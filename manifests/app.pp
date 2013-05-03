exec {
 'apt-get-update':
    path    => '/usr/bin',
    command => 'apt-get update'
}
package {
 'htop':
    ensure  => present,
    require => Exec['apt-get-update']
}
package{
 'git-core':
    ensure  => present
}
package{
 'vim':
    ensure  => present
}
package{
 'curl':
    ensure  => present
}
package{
 'acl':
    ensure  => present
}
package{
 'wget':
    ensure  => present
}
package{
 'drush':
    ensure  => present,
    require => Exec['apt-get-update']
}
package{
 'openjdk-7-jre-headless':
    ensure  => present,
    require => Exec['apt-get-update']
}
package{
 'tar':
    ensure  => present
}
class {
 'apache': 
    require => Exec['apt-get-update'],
}
apache::module {'rewrite': }
apache::module {'env': }
apache::module {'deflate': }
apache::module {'expires': }

class {
 'mysql': 
    root_password => root,
        require   => Exec['apt-get-update'],
}
class { 
 'php':     
    require => Exec['apt-get-update']
}

php::module { 'cli': }
php::module { 'curl': }
php::module { 'mcrypt': }
php::module { 'intl': }
php::module { 'sqlite': }
php::module { 'xdebug': }
php::module {
 'apc': 
  module_prefix => 'php-'
}
php::module {
 'pear':
  module_prefix => 'php-'
}

package{
 'sendmail':
    ensure  => present,
    require => Exec['apt-get-update']
}
package{
 'phpmyadmin':
    ensure  => present,
    require => [Class['php'], Class['mysql']]
}

exec {
 'pear-auto-discover':
    path    => '/usr/bin:/usr/sbin:/bin',
    onlyif  => 'test "`pear config-get auto_discover`" = "0"',
    command => 'pear config-set auto_discover 1 system',
    require => Php::Module['cli']
}
exec {
 'pear-update':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => 'pear update-channels && pear upgrade-all',
    require => Php::Module['cli']
}
exec {
 'install-phpunit':
    unless  => '/usr/bin/which phpunit',
    command => '/usr/bin/pear install pear.phpunit.de/PHPUnit --alldeps',
    require => [Php::Module['cli'], Exec['pear-auto-discover'], Exec['pear-update']]
}
exec {
 'install-phpqatools':
    unless  => '/usr/bin/which phpcs',
    command => '/usr/bin/pear install pear.phpqatools.org/phpqatools --alldeps',
    require => [Php::Module['cli'], Exec['pear-auto-discover'], Exec['pear-update']]
}
exec {
 'install-phpdocumentor':
    unless  => '/usr/bin/which phpdoc',
    command => '/usr/bin/pear install pear.phpdoc.org/phpDocumentor-alpha --alldeps',
    require => [Php::Module['cli'], Exec['pear-auto-discover'], Exec['pear-update']]
}

file {
 '/home/vagrant/code/web':
    ensure  => 'directory',
}
exec {
 'download-composer':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => 'curl -s https://getcomposer.org/installer | php -- --install-dir=/home/vagrant/code/web/',
    require => [Package['curl'],Php::Module['cli'],File['/home/vagrant/code/web']],
}
file {
 'php_apachephpini':
    path    => '/etc/php5/apache2/php.ini',
    ensure  => present,
    source  => '/home/vagrant/code/resources/php.ini',
    require => Php::Module['cli'],
}
file {
 'php_cliphpini':
    path    => '/etc/php5/cli/php.ini',
    ensure  => '/etc/php5/apache2/php.ini',
    require => File['php_apachephpini'],
}
file {
 'php_mcrypt':
    path    => '/etc/php5/conf.d/mcrypt.ini',
    ensure  => '/home/vagrant/code/resources/mcrypt.ini',
    require => File['php_apachephpini'],
}

file {
 'apache2.default-vhost':
    path    => '/etc/apache2/sites-available/default',
    ensure  => present,
    source  => '/home/vagrant/code/resources/apache2-default-vhost',
    require => Php::Module['cli'],
}
file {
 '/home/vagrant/code/web/adminer':
    ensure  => 'directory',
}
file {
 '/home/vagrant/servers':
    ensure  => 'directory',
}
exec{
 'download_adminer':
    path    => '/usr/bin:/usr/sbin:/bin',
    cwd     => '/home/vagrant/code/web/adminer/',
    command => 'wget http://www.adminer.org/latest-mysql-en.php -O adminer.php',
    require => File['/home/vagrant/code/web/adminer'],
}
file {
 'apache2.adminer-vhost':
    path    => '/etc/apache2/sites-available/adminer',
    ensure  => present,
    source  => '/home/vagrant/code/resources/apache2-adminer-vhost',
    require => File['/home/vagrant/code/web'],
}
file {
 'apache2.solrtest-vhost':
    path    => '/etc/apache2/sites-available/solrtest',
    ensure  => present,
    source  => '/home/vagrant/code/resources/apache2-solrtest-vhost',
    require => File['/home/vagrant/code/web'],
}
file {
 'apache2.solrtest2-vhost':
    path    => '/etc/apache2/sites-available/solrtest2',
    ensure  => present,
    source  => '/home/vagrant/code/resources/apache2-solrtest2-vhost',
    require => File['/home/vagrant/code/web'],
}
host { 
 'adminer':
    ip           => '127.0.0.1',
    host_aliases => 'adminer.dev',
}
host { 
 'solrtest':
    ip           => '127.0.0.1',
    host_aliases => 'solrtest.dev',
}
host { 
 'solrtest2':
    ip           => '127.0.0.1',
    host_aliases => 'solrtest2.dev',
}
exec{
 'apache2_en_site_adminer':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => 'a2ensite adminer',
    require => File['apache2.adminer-vhost']
}
exec{
 'apache2_en_site_solrtest':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => 'a2ensite solrtest',
    require => File['apache2.solrtest-vhost']
}
exec{
 'apache2_en_site_solrtest2':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => 'a2ensite solrtest2',
    require => File['apache2.solrtest2-vhost']
}
exec{
 'restart_apache2':
    path    => '/usr/bin:/usr/sbin:/bin',
    command => 'service apache2 restart',
    require => Exec['apache2_en_site_adminer']
}


exec{
 'download_solr':
    path    => '/usr/bin:/usr/sbin:/bin',
    cwd     => '/tmp',
    creates  =>  "/tmp/solr-4.2.1.tgz",
    command => 'wget http://apache.cu.be/lucene/solr/4.2.1/solr-4.2.1.tgz -O solr-4.2.1.tgz',
    require => Exec['restart_apache2'],
}
exec { 'install_solr':
  path    => '/usr/bin:/usr/sbin:/bin',
  cwd => '/tmp',
  command => 'tar xvzf solr-4.2.1.tgz  -C /home/vagrant/servers',
  creates => '/home/vagrant/server/solr',
  require => Exec['download_solr'],
}

#drupal things
exec { 'drush-download-drupal':
  path    => '/usr/bin:/usr/sbin:/bin',
  cwd     => '/home/vagrant/code/web',
  unless  => 'test -d /home/vagrant/code/web/solrtest',
  command => 'git clone git://github.com/drupal/drupal.git solrtest && cd solrtest && git checkout -b drupal7 remotes/origin/7.x',
  require => Exec['install_solr'],
}
#
exec { 'drush-download-modules':
  path    => '/usr/bin:/usr/sbin:/bin',
  cwd     => '/home/vagrant/code/web/solrtest',
  command => 'drush dl apachesolr devel features ctools strongarm node_export uuid drush_ctex_bonus --destination=/home/vagrant/code/web/solrtest/sites/all/modules',
  require => Exec['drush-download-drupal'],
}


file { [ '/home/vagrant/code/web/solrtest/',
         '/home/vagrant/code/web/solrtest/sites',
         '/home/vagrant/code/web/solrtest/sites/all/',
         '/home/vagrant/code/web/solrtest/sites/all/modules' ]:
  ensure => directory,
require => Exec['drush-download-modules'],
}
cron { 'drupal-cron-solrtest':
  command => 'wget -O - -q -t 1 http://solrtest.dev/cron.php',
  hour => inline_template('<%= name.hash % 24 %>'),
  minute => "00",
}
exec { 'create-solrtest':
  unless => '/usr/bin/mysql -uroot -proot drupal',
  command => '/usr/bin/mysql -uroot -proot -e "create database drupal;"',
  require => Exec['drush-download-modules'],
}
