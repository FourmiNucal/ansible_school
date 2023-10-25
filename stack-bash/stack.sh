#!/bin/bash

SERVER=$1
DATABASE=$2
LANGUAGE=$3
RELEASE_ID=`cat /etc/os-release | grep ID | head -n 1 | cut -d "=" -f2 | tr -d '"'`
INSTALL_ERROR_MESSAGE="echo -e \n\e[31mProblème lors de l'installation. Consultez les messages ci-dessus.\e[0m\n" 

# pour de l'aide
if [ "$1" == "--help" ]; then
  echo -e "Utilisation: \e[32m stack.sh [apache|nginx] [mariadb|postgresql] [php|python] \e[0m"
  exit 0
fi

# validation des trois paramètres

if [ "$#" != 3 ]; then
  echo -e "Erreur: \e[32m Veuillez rentrer 3 paramètres \e[0m"
  exit 1
fi

# validation du contenu des param
#serveur web
if [ "$SERVER" != "apache" ] && [ "$SERVER" != "nginx" ]; then
  echo -e "Erreur: \e[32m Veuillez rentrer un serveur web valide \e[0m"
  exit 2
fi
#base de données
if [ "$DATABASE" != "mariadb" ] && [ "$DATABASE" != "postgresql" ]; then
  echo -e "Erreur: \e[32m Veuillez rentrer une base de données valide \e[0m"
  exit 2
fi
#language de programmation
if [ "$LANGUAGE" != "php" ] && [ "$LANGUAGE" != "python" ]; then
  echo -e "Erreur: \e[32m Veuillez rentrer un language de programmation valide \e[0m"
  exit 2
fi

PACKAGE_INSTALL_COMMAND="apt install --assume-yes"
PACKAGES_WEB=(apache2 nginx)
PACKAGES_DATABASE=(mariadb-server postgresql)
PACKAGES_PHP=(php-fpm php-mysql php-pgsql)
PACKAGES_PYTHON=(python3-pip libmariadb-dev libpq-dev)
PACKAGEPIP_INSTALL_COMMAND="pip3 install"
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
  # set up un test
  if [ "$SERVER" = "nginx" ] && [ "$LANGUAGE" = "php" ]; then 
   cp -f /root/stack/php/nginx-default /etc/nginx/sites-available/default
  fi

  if [ "$SERVER" = "nginx" ] && [ "$LANGUAGE" = "python" ]; then
    cp -f /root/stack/python/nginx-default-ubuntu /etc/nginx/sites-available/default
  fi

  if [ "$SERVER" = "apache" ] && [ "$LANGUAGE" = "php" ]; then
    cp -f /root/stack/php/apache-default /etc/apache2/sites-available/default
  fi

  if [ "$SERVER" = "apache" ] && [ "$LANGUAGE" = "python" ]; then
    cp -f /root/stack/python/apache-default /etc/apache2/sites-available/default
  fi
}

# [installation de la base de données (MariaDB ou PostgreSQL)]
database() {
  echo -e "\n\e[94mInstallation de la base de données \e[33m$DATABASE\e[94m...\e[0m"
  # install la db
  if [ "$DATABASE" = "mariadb" ]; then
     $PACKAGE_INSTALL_COMMAND ${PACKAGES_DATABASE[0]}
  else
     $PACKAGE_INSTALL_COMMAND ${PACKAGES_DATABASE[1]}
  fi

  # création d'une db maria avec un utilisateur test
  if [ "$DATABASE" = "mariadb" ]; then 
    mysql -u root -e "CREATE DATABASE test;" 
    mysql -u root -e "CREATE USER 'test_u'@'localhost' IDENTIFIED BY 'Test123';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON test.* TO 'test_u'@'localhost';"
    mysql -u root -e "FLUSH PRIVILEGES;"
 else
 sudo su postgres <<EOF
    cd
    createdb test;
    psql -c "CREATE USER test_u WITH PASSWORD 'Test123';"
    psql -c "grant all privileges on database test to test_u;"
EOF
  fi
}

# [installation du langage de programmation (PHP ou Python)]
language() {
  echo -e "\n\e[94mInstallation du langage de programmation \e[33m$LANGUAGE\e[94m...\e[0m"
  if [ "$LANGUAGE" = "php" ]; then 
    $PACKAGE_INSTALL_COMMAND $PACKAGES_PHP
    cp /root/stack/php/index.php /var/www/html
  else
    $PACKAGE_INSTALL_COMMAND $PACKAGES_PYTHON
    $PACKAGEPIP_INSTALL_COMMAND $PACKAGES_PYTHON_PIP
    cp -R /root/stack/python/testapp /var/www/html
    chown www-data /var/www/html/testapp
    cp -f /root/stack/python/testapp.service /etc/systemd/system
    sed 's/%USER%/www-data/' /etc/systemd/system/testapp.service
    systemctl daemon-reload
    systemctl enable testapp.service
    systemctl start testapp.service
  fi
}

#[appel de chacune des fonctions et validation de leur retour]
echo -e "\n\n\e[32mInstallation de la pile \e[33m$SERVER\e[32m + \e[33m$DATABASE\e[32m + \e[33m$LANGUAGE\e[32m complétée avec succès !\e[0m\n"
# call
server PACKAGE_INSTALL_COMMAND  PACKAGES_WEB 
database PACKAGE_INSTALL_COMMAND PACKAGES_DATABASE
language PACKAGE_INSTALL_COMMAND PACKAGEPIP_INSTALL_COMMAND PACKAGES_PHP PACKAGES_PYTHON

if ! server; then
	$INSTALL_ERROR_MESSAGE
fi

if ! database; then
	$INSTALL_ERROR_MESSAGE
fi

if ! language; then
	$INSTALL_ERROR_MESSAGE
fi

echo -e "\n\n\e[32mInstallation de la pile \e[33m$SERVER\e[32m + \e[33m$DATABASE\e[32m + \e[33m$LANGUAGE\e[32m complétée avec succès !\e[0m\n"