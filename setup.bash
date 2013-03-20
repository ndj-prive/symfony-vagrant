#!/usr/bin/env bash

git submodule update --init
git submodule update --recursive

#create a standard vhost file ready to move
PROJECTNAME=${PWD##*/}

touch $PROJECTNAME
echo "<Virtualhost *:80>" > "$PROJECTNAME"
echo "" >> "$PROJECTNAME"
echo "    ServerAdmin info@dejonghenico.be" > "$PROJECTNAME"
echo "    ServerName $PROJECTNAME.dev" >> "$PROJECTNAME"
echo "" >> "$PROJECTNAME"
echo "    Documentroot /home/vagrant/code/web/$PROJECTNAME/web" >> "$PROJECTNAME"
echo "" >> "$PROJECTNAME"
echo "    <Directory />" >> "$PROJECTNAME"
echo "        Options FollowSymLinks" >> "$PROJECTNAME"
echo "        AllowOverride all" >> "$PROJECTNAME"
echo "    </Directory>" >> "$PROJECTNAME"
echo "    <Directory /home/vagrant/code/web/$PROJECTNAME/web>" >> "$PROJECTNAME"
echo "        Options Indexes FollowSymLinks MultiViews" >> "$PROJECTNAME"
echo "        #DirectoryIndex index.php" >> "$PROJECTNAME"
echo "        AllowOverride all" >> "$PROJECTNAME"
echo "        Order allow,deny" >> "$PROJECTNAME"
echo "        allow from all" >> "$PROJECTNAME"
echo "    </Directory>" >> "$PROJECTNAME"
echo "" >> "$PROJECTNAME"
echo "    ErrorLog /var/log/apache2/error.log" >> "$PROJECTNAME"
echo "" >> "$PROJECTNAME"
echo "    # Possible values include: debug, info, notice, warn, error, crit," >> "$PROJECTNAME"
echo "    # alert, emerg." >> "$PROJECTNAME"
echo "    LogLevel warn" >> "$PROJECTNAME"
echo "" >> "$PROJECTNAME"
echo "    CustomLog /var/log/apache2/access.log combined" >> "$PROJECTNAME"
echo "" >> "$PROJECTNAME"
echo "</VirtualHost>" >> "$PROJECTNAME"

cd vagrant
vagrant up
