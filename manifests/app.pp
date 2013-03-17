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

class { "mysql": 
    root_password => root,
        require => Exec["apt-get-update"],
}

class { 'php':     require => Exec["apt-get-update"]}
php::module { "cli": }
php::module { "curl": }
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

exec { 'download-composer':
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'curl -s https://getcomposer.org/installer | php -- --install-dir=/home/vagrant/code/web',
    require => [Package['curl'],Php::Module['cli'],Exec['create-dir']]
}

exec { 'download-symfony2':
    path => '/usr/bin:/usr/sbin:/bin',
    command => 'php /home/vagrant/code/web/composer.phar create-project symfony/framework-standard-edition /home/vagrant/code/web/project',
    require => Php::Module['cli']
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
