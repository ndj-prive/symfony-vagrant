exec { 'apt-get-update':
    path => '/usr/bin',
    command => 'apt-get update'
}

package { 'htop':
    ensure  => present,
    require => Exec['apt-get-update']
}

package{'git-core':
    ensure  => present
}

package{'vim':
    ensure  => present
}

package{'curl':
    ensure  => present
}

package{'acl':
    ensure  => present
}

class { "apache": 
    require => Exec["apt-get-update"],
}
apache::module {'rewrite': }
apache::module {'env': }
apache::module {'deflate': }
apache::module {'expires': }

apache::vhost { 'projectname.dev':
    docroot             => '/var/www/document_root/test',
    template            => '/home/vagrant/code/resources/apache2-project-vhost',
}

host { "projectname.dev":
  ip => "33.33.33.10",
}

host { "adminer.dev":
  ip => "33.33.33.10",
}

class { "mysql": 
    root_password => root,
        require => Exec["apt-get-update"],
}

mysql::grant { 'iamhacked':
  mysql_privileges => 'ALL',
  mysql_password => 'root',
  mysql_db => 'iamhacked',
  mysql_user => 'iamhacked',
  mysql_host => 'localhost',
}

class { 'php':     require => Exec["apt-get-update"]}
php::module { "cli": }
php::module { "curl": }
php::module { "mcrypt": }
php::module { "intl": }
php::module { "sqlite": }
php::module { "apc": 
  module_prefix => "php-"
}
php::module { "pear":
  module_prefix => "php-"
}
php::module { "xdebug": }

package{ 'sendmail':
    ensure  => present,
    require => Exec['apt-get-update']
}

package{ 'phpmyadmin':
    ensure  => present,
    require => [Class['php'], Class['mysql']]
}

exec { 'pear-auto-discover':
    path => '/usr/bin:/usr/sbin:/bin',
    onlyif => 'test "`pear config-get auto_discover`" = "0"',
    command => 'pear config-set auto_discover 1 system',
    require => Php::Module['cli']
}
exec { 'pear-update':
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'pear update-channels && pear upgrade-all',
    require => Php::Module['cli']
}
exec { 'install-phpunit':
    unless => "/usr/bin/which phpunit",
    command => '/usr/bin/pear install pear.phpunit.de/PHPUnit --alldeps',
    require => [Php::Module['cli'], Exec['pear-auto-discover'], Exec['pear-update']]
}
exec { 'install-phpqatools':
    unless => "/usr/bin/which phpcs",
    command => "/usr/bin/pear install pear.phpqatools.org/phpqatools --alldeps",
    require => [Php::Module['cli'], Exec['pear-auto-discover'], Exec['pear-update']]
}
exec { 'install-phpdocumentor':
    unless => "/usr/bin/which phpdoc",
    command => "/usr/bin/pear install pear.phpdoc.org/phpDocumentor-alpha --alldeps",
    require => [Php::Module['cli'], Exec['pear-auto-discover'], Exec['pear-update']]
}

exec { 'create-dir':
    path => '/usr/bin:/usr/sbin:/bin',
    command => "mkdir -p /home/vagrant/code/web",
    unless => "[ -d '/home/vagrant/code/web' ]"
}

#download composer
exec { 'download-composer':
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'curl -s https://getcomposer.org/installer | php -- --install-dir=/home/vagrant/code/web',
    require => [Package['curl'],Php::Module['cli'],Exec['create-dir']]
}


file { 'php_apachephpini':
    path    => '/etc/php5/apache2/php.ini',
    ensure  => present,
    source  => '/home/vagrant/code/resources/php.ini',
    require => Php::Module['cli']
}

file 
{ 'php_cliphpini':
    path    => '/etc/php5/cli/php.ini',
    ensure  => '/etc/php5/apache2/php.ini',
    require => File['php_apachephpini']
}

file 
{'php_mcrypt':
    path    => '/etc/php5/conf.d/mcrypt.ini',
    ensure  => '/home/vagrant/code/resources/mcrypt.ini',
    require => File['php_apachephpini']
}

file {'apache2.default-vhost':
    path    => '/etc/apache2/sites-available/default',
    ensure  => present,
    source  => '/home/vagrant/code/resources/apache2-default-vhost',
    require => Php::Module['cli']
}


$tmp_path        = '/home/vagrant'
$php_package     = 'php5-cli'

exec { 'download_composer':
      path => '/usr/bin:/usr/sbin:/bin',
      command     => 'curl -s http://getcomposer.org/installer | php',
      cwd         => "$tmp_path/code/web",
      require     => [
        Package['curl', $php_package],
      ],
      creates     => "$tmp_path/code/web/composer.phar",
}

exec { 'download_behat':
      path => '/usr/bin:/usr/sbin:/bin',
      command     => 'curl -O http://behat.org/downloads/symfony2_extension.phar',
      cwd         => "$tmp_path/code/web",
      require     => [
        Package['curl', $php_package],
      ],
      creates     => "$tmp_path/code/web/symfony2_extension.phar",
}

exec { 'download_mink':
      path => '/usr/bin:/usr/sbin:/bin',
      command     => 'curl -O http://behat.org/downloads/mink.phar',
      cwd         => "$tmp_path/code/web",
      require     => [
        Package['curl', $php_package],
      ],
      creates     => "$tmp_path/code/web/mink.phar",
}

exec { 'download_mink_extention':
      path => '/usr/bin:/usr/sbin:/bin',
      command     => 'curl -O http://behat.org/downloads/mink_extension.phar',
      cwd         => "$tmp_path/code/web",
      require     => [
        Package['curl', $php_package],
      ],
      creates     => "$tmp_path/code/web/mink_extension.phar",
}




# Install rubygems
package { "rubygems": ensure => latest }

# Install capifony and add it to path
package { "capifony":
    ensure   => latest,
    provider => gem,
    require  => Package["rubygems"]
}

package { "capistrano-ext":
    ensure   => latest,
    provider => gem,
    require  => Package["rubygems"]
}

cron { "backup db":
  command => "/usr/bin/mysqldump -uiamhacked -proot iamhacked > $tmp_path/code/dump.sql",
  user    => root,
  hour    => '2',
  minute  => '0'
}

exec { 'create-dir-adminer':
    path => '/usr/bin:/usr/sbin:/bin',
    command => "mkdir -p $tmp_path/code/web",
    unless => "[ -d '/$tmp_path/code/web' ]",
}

#exec { 'download_adminer':
#      path => '/usr/bin:/usr/sbin:/bin',
#      command     => 'curl -O http://downloads.sourceforge.net/adminer/adminer-3.6.3.ph',
#      cwd         => "$tmp_path/code/web/adminer/",
#      require     => [
#        Package['curl'],Exec["create-dir-adminer"]
#      ],
#      creates     => "tmp_path/code/web/adminer/adminer.php",
#}
