#!/bin/bash

if [ ! -f .initialized ]; then
  mv wp-config-sample.php wp-config.php
  sed -i s/localhost/db/ wp-config.php
  sed -i s/database_name_here/$MYSQL_DATABASE/ wp-config.php
  sed -i s/username_here/$MYSQL_USER/ wp-config.php
  sed -i s/password_here/$MYSQL_PASSWORD/ wp-config.php
  sed -i "s/define('AUTH_KEY',\s*'put your unique phrase here');/define('AUTH_KEY', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define('SECURE_AUTH_KEY',\s*'put your unique phrase here');/define('SECURE_AUTH_KEY', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define('LOGGED_IN_KEY',\s*'put your unique phrase here');/define('LOGGED_IN_KEY', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define('NONCE_KEY',\s*'put your unique phrase here');/define('NONCE_KEY', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define('AUTH_SALT',\s*'put your unique phrase here');/define('AUTH_SALT', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define('SECURE_AUTH_SALT',\s*'put your unique phrase here');/define('SECURE_AUTH_SALT', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define('LOGGED_IN_SALT',\s*'put your unique phrase here');/define('LOGGED_IN_SALT', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define('NONCE_SALT',\s*'put your unique phrase here');/define('NONCE_SALT', '`pwgen -1 -s 64`');/" wp-config.php
  echo "define('FS_METHOD', 'direct');" >> wp-config.php

  if [ $PORT = "80" ]; then
    echo "define( 'WP_HOME', 'http://localhost' );" >> wp-config.php
    echo "define( 'WP_SITEURL', 'http://localhost' );" >> wp-config.php
  else
    echo "define( 'WP_HOME', 'http://localhost:$PORT' );" >> wp-config.php
    echo "define( 'WP_SITEURL', 'http://localhost:$PORT' );" >> wp-config.php
  fi

  echo 'Updating apache conf'

  sed -i s/:80/:$PORT/ /etc/apache2/sites-available/*.conf
  sed -i s/:443/:$SSL_PORT/ /etc/apache2/sites-available/*.conf
  sed -i s/80/$PORT/ /etc/apache2/ports.conf
  sed -i s/443/$SSL_PORT/ /etc/apache2/ports.conf

  touch .initialized
fi

exec apache2-foreground