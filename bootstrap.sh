#!/usr/bin/env bash

# Adapted from:
# http://www.websightdesigns.com/posts/view/how-to-configure-an-ubuntu-web-server-vm-with-vagrant

# Variables
DBHOST=localhost
DBNAME=wedeml
DBUSER=dbuser
DBROOTPASSWD=rootpassword
DBUSERPASSWD=password

echo ----
echo ---- PACKAGE INSTALLATIONS
echo ----

sudo apt-get update # 2> /dev/null
sudo apt-get upgrade # 2> /dev/null

sudo apt-get install -y make # 2> /dev/null

sudo apt-get install -y git # 2> /dev/null
sudo apt-get install -y emacs # 2> /dev/null
sudo apt-get install -y vim # 2> /dev/null

sudo apt-get install -y apache2 # 2> /dev/null
sudo apt-get install -y openssl # 2> /dev/null

echo ----
echo ---- APACHE SETUP
echo ----

APACHEUSR=`grep -c 'APACHE_RUN_USER=www-data' /etc/apache2/envvars`
APACHEGRP=`grep -c 'APACHE_RUN_GROUP=www-data' /etc/apache2/envvars`
if [ APACHEUSR ]; then
    sed -i 's/APACHE_RUN_USER=www-data/APACHE_RUN_USER=vagrant/' /etc/apache2/envvars
fi
if [ APACHEGRP ]; then
    sed -i 's/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=vagrant/' /etc/apache2/envvars
fi
sudo chown -R vagrant:www-data /var/lock/apache2

echo ----
echo ---- MORE APACHE CONFIGURATION
echo ----

# if /var/www is not a symlink then create the symlink and set up apache
if [ ! -h /var/www/html ];
then
    rm -rf /var/www/html
    ln -fs /vagrant /var/www/html
    sudo a2enmod rewrite
    sudo a2enmod cgid

    # Set up our virtual host

    VHOST=$(cat <<EOF
 <VirtualHost *:80>
    #ServerName www.example.com

    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
    # error, crit, alert, emerg.
    # It is also possible to configure the loglevel for particular
    # modules, e.g.
    #LogLevel info ssl:warn

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks +ExecCGI
        AllowOverride All
        Order allow,deny
        Allow from all
        
        AddHandler cgi-script .cgi
    </Directory>
</VirtualHost>
EOF
)
    echo "${VHOST}" > /etc/apache2/sites-enabled/000-default.conf

    # Set development environment flag
    APACHE_ARGUMENTS_LINE="#export APACHE_ARGUMENTS=''"
    REPLACEMENT="export APACHE_ARGUMENTS='-Ddev'"
    sudo sed -ie "s/$APACHE_ARGUMENTS_LINE/$REPLACEMENT/" /etc/apache2/envvars

    sudo service apache2 restart # 2> /dev/null
fi

# restart apache
sudo service apache2 reload # 2> /dev/null

echo ----
echo ---- INSTALL MYSQL
echo ----

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBROOTPASSWD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBROOTPASSWD"
sudo apt-get install -y mysql-server # 2> /dev/null
sudo apt-get install -y mysql-client # 2> /dev/null

echo ----
echo ---- MYSQL SETUP: $DBNAME DATABASE
echo ----

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBROOTPASSWD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBROOTPASSWD"
sudo apt-get install -y mysql-server # 2> /dev/null
sudo apt-get install -y mysql-client # 2> /dev/null
sudo apt-get install -y libmysqlclient-dev

if [ ! -d /var/lib/mysql/$DBNAME ];
then
    echo ----
    echo ---- Creating $DBNAME, granting all on $DBNAME.* to $DBUSER
    echo ----

    echo "CREATE USER '$DBUSER'@'%' IDENTIFIED BY '$DBUSERPASSWD'" | mysql -uroot -p$DBROOTPASSWD
    echo "CREATE DATABASE $DBNAME" | mysql -uroot -p$DBROOTPASSWD
    echo "GRANT ALL ON $DBNAME.* TO '$DBUSER'@'%'" | mysql -uroot -p$DBROOTPASSWD

    echo ----
    echo ---- flushing
    echo ----

    echo "flush privileges" | mysql -uroot -p$DBROOTPASSWD

    echo ----
    echo ---- Creating schema
    echo ----

    echo "CREATE TABLE $DBNAME.email ( ID int NOT NULL AUTO_INCREMENT, name VARCHAR(255), email VARCHAR(255), primary key (ID) )"  | mysql -uroot -p$DBROOTPASSWD
fi

echo ---
echo --- CONFIGURE RUBY
echo ---

sudo apt-get install -y ruby-dev
sudo gem install mysql2
