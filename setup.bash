#!/usr/bin/env bash

#git submodule update --init
#git submodule update --recursive

#create a standard vhost file ready to move
PROJECTNAME=${PWD##*/}

VHOSTPATH="resources/apache2-project-vhost"

touch $VHOSTPATH
echo "<Virtualhost *:80>" > $VHOSTPATH
echo "" >> $VHOSTPATH
echo "   SetEnv FLATCLUB_ENV dev" >> $VHOSTPATH
echo "   SetEnv FLATCLUB_DEBUG true" >> $VHOSTPATH
echo "" >> $VHOSTPATH
echo "    ServerAdmin info@dejonghenico.be" >> $VHOSTPATH
echo "    ServerName $PROJECTNAME.dev" >> $VHOSTPATH
echo "" >> $VHOSTPATH
echo "    Documentroot /home/vagrant/code/web/$PROJECTNAME/web" >> $VHOSTPATH
echo "" >> $VHOSTPATH
echo "    <Directory />" >> $VHOSTPATH
echo "        Options FollowSymLinks" >> $VHOSTPATH
echo "        AllowOverride all" >> $VHOSTPATH
echo "    </Directory>" >> $VHOSTPATH
echo "    <Directory /home/vagrant/code/web/$PROJECTNAME/web>" >> $VHOSTPATH
echo "        Options Indexes FollowSymLinks MultiViews" >> $VHOSTPATH
echo "        #DirectoryIndex index.php" >> $VHOSTPATH
echo "        AllowOverride all" >> $VHOSTPATH
echo "        Order allow,deny" >> $VHOSTPATH
echo "        allow from all" >> $VHOSTPATH
echo "    </Directory>" >> $VHOSTPATH
echo "" >> $VHOSTPATH
echo "    ErrorLog /var/log/apache2/error.log" >> $VHOSTPATH
echo "" >> $VHOSTPATH
echo "    # Possible values include: debug, info, notice, warn, error, crit," >> $VHOSTPATH
echo "    # alert, emerg." >> $VHOSTPATH
echo "    LogLevel warn" >> $VHOSTPATH
echo "" >> $VHOSTPATH
echo "    CustomLog /var/log/apache2/access.log combined" >> $VHOSTPATH
echo "" >> $VHOSTPATH
echo "</VirtualHost>" >> $VHOSTPATH

git clone git://github.com/ndj-prive/git.git git-hooks


cd vagrant
vagrant up
