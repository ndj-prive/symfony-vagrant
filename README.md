symfony-vagrant
===============

Vagrant + puppet configuration for Symfony project

[Draft]

Requirements: 
	
	ruby, vagrant, virtualbox

Install ruby:

	$ sudo apt-get install ruby or $ brew install ruby

Donwload and install virtualbox:

	url: https://www.virtualbox.org/

Install vagrant:

	$ gem install vagrant

Time to rock:

Download the vagrant repo.

	$ git clone git@github.com:ndj-prive/symfony-vagrant.git <project-name>

Move into the downloaded folder

	$ cd <project-name>

Let our local git repo know we have submodules

    $ git submodule update --init

Download the submodules in one line

	$ git submodule update --recursive

Vagrant time

	$ vagrant up

SSH into your new vagrantbox

	vagrant ssh

enjoy

Original developed by: 
	https://github.com/ftassi
	https://github.com/example42