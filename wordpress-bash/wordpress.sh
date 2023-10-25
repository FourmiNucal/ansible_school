#!/bin/bash

SERVER=$1
INSTALL_ERROR_MESSAGE="echo -e \n\e[31mProblème lors de l'installation. Consultez les messages ci-dessus.\e[0m\n" 

# validation du contenu des param
#serveur web
if [ "$SERVER" != "apache" ] && [ "$SERVER" != "nginx" ]; then
  echo -e "Erreur: \e[32m Veuillez rentrer un serveur web valide \e[0m"
  exit 2
fi

PACKAGE_INSTALL_COMMAND="apt install --assume-yes"
PACKAGES_WEB=(apache2 nginx)
PACKAGES_DATABASE=(mariadb-server)
PACKAGES_PHP=(php-fpm php-mysql php-pgsql)
echo -e "\n\e[94mPréparation de votre système...\e[0m"
apt update
# functions

# [installation du serveur web (Apache ou NGINX)]
server() {
  echo -e "\n\e[94mInstallation du serveur web \e[33m$SERVER\e[94m...\e[0m"
  # install le server
  if [ "$SERVER" = "apache" ]; then
   $PACKAGE_INSTALL_COMMAND ${PACKAGES_WEB[0]}
  else
   $PACKAGE_INSTALL_COMMAND ${PACKAGES_WEB[1]}
  fi

# php
  $PACKAGE_INSTALL_COMMAND $PACKAGES_PHP
    cp /root/stack/php/index.php /var/www/html

  #setup
  if [ "$SERVER" = "nginx" ]; then 
   cp -f /root/stack/php/nginx-default /etc/nginx/sites-available/default
   mkdir -p /var/www/html/wordpressexamen.com/public_html
   cp /etc/nginx/sites-enabled/default /etc/nginx/sites-available/wordpressexamen.com.conf

   nginx -s reload
  else
   cp -f /root/stack/php/apache-default /etc/apache2/sites-available/default
   mkdir -p /var/www/html/wordpressexamen.com/public_html
   cp /etc/apache2/sites-enabled/default /etc/apache2/sites-available/default
  fi

  systemctl restart php7.4-fpm
}

database() {
  echo -e "\n\e[94mInstallation de la base de données maridb"
  # install la db
  
  $PACKAGE_INSTALL_COMMAND $PACKAGES_DATABASE

  # création d'une db maria avec un utilisateur test 
  mysql -u root -e "CREATE DATABASE wordpress;" 
  mysql -u root -e "CREATE USER 'wordpress_u'@'localhost' IDENTIFIED BY 'wordpress123';"
  mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress_u'@'localhost';"
  mysql -u root -e "FLUSH PRIVILEGES;"
  
  systemctl restart mysql.service
  systemctl restart mariadb.service
}

wordpress() {
 if [ "$SERVER" = "apache" ]; then
     # rewrite module
     a2enmod rewrite
     systemctl restart apache2
   else
     unlink /etc/nginx/sites-enabled/default
     systemctl restart nginx
 fi

  mysql -u root -e CREATE DATABASE wordpress;
  mysql -u root -e CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'password';
  mysql -u root -e GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
  mysql -u root -e FLUSH PRIVILEGES;

  # install
   mkdir -p /var/www/html/wordpressexamen.com/src
   cd /var/www/html/wordpressexamen.com/src
   wget http://wordpress.org/latest.tar.gz
   tar -xvf latest.tar.gz
   mv wordpress/* ../public_html/
   chown -R www-data:www-data /var/www/html/wordpressexamen.com
}

# appel des fonctions 
server PACKAGE_INSTALL_COMMAND  PACKAGES_WEB PACKAGES_PHP
database PACKAGE_INSTALL_COMMAND PACKAGES_DATABASE
wordpress 


if ! server; then
	$INSTALL_ERROR_MESSAGE
fi


echo -e "\n\n\e[32mInstallation de la pile \e[33m$SERVER\e[32m\e[0m\n"