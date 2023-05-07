#!/bin/bash

mysqld_safe &

sleep 10

if [ ! -f /src/.initialized ]; then

  # setup the database
  mysql -e "set global sql_mode = '';"
  mysql -e "CREATE DATABASE ${MYSQL_DATABASE} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
  mysql -e "CREATE USER ${MYSQL_USER}@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
  mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
  mysql -e "FLUSH PRIVILEGES;"

  # wordpress conflicts

  # restore database file
  for FILE in /src/db/*; do mysql $MYSQL_DATABASE < $FILE; done

  # configure wordpress
  mv wp-config-sample.php wp-config.php
  sed -i s/localhost/127\.0\.0\.1/ wp-config.php
  sed -i s/database_name_here/$MYSQL_DATABASE/ wp-config.php
  sed -i s/username_here/$MYSQL_USER/ wp-config.php
  sed -i s/password_here/$MYSQL_PASSWORD/ wp-config.php
  sed -i "s/'wp_'/'$WP_PREFIX'/" wp-config.php
  sed -i "s/define(\s*'AUTH_KEY',\s*'put your unique phrase here'\s*);/define('AUTH_KEY', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define(\s*'SECURE_AUTH_KEY',\s*'put your unique phrase here'\s*);/define('SECURE_AUTH_KEY', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define(\s*'LOGGED_IN_KEY',\s*'put your unique phrase here'\s*);/define('LOGGED_IN_KEY', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define(\s*'NONCE_KEY',\s*'put your unique phrase here'\s*);/define('NONCE_KEY', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define(\s*'AUTH_SALT',\s*'put your unique phrase here'\s*);/define('AUTH_SALT', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define(\s*'SECURE_AUTH_SALT',\s*'put your unique phrase here'\s*);/define('SECURE_AUTH_SALT', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define(\s*'LOGGED_IN_SALT',\s*'put your unique phrase here'\s*);/define('LOGGED_IN_SALT', '`pwgen -1 -s 64`');/" wp-config.php
  sed -i "s/define(\s*'NONCE_SALT',\s*'put your unique phrase here'\s*);/define('NONCE_SALT', '`pwgen -1 -s 64`');/" wp-config.php
  echo "define( 'FS_METHOD', 'direct' );" >> wp-config.php

  if [ $PORT = "80" ]; then
    echo "define( 'WP_HOME', 'http://localhost' );" >> wp-config.php
    echo "define( 'WP_SITEURL', 'http://localhost' );" >> wp-config.php
    mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "UPDATE ${PREFIX}options SET option_value='http://localhost' WHERE option_name in ('home', 'siteurl');"
  else
    echo "define( 'WP_HOME', 'http://localhost:$PORT' );" >> wp-config.php
    echo "define( 'WP_SITEURL', 'http://localhost:$PORT' );" >> wp-config.php
    mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "UPDATE ${PREFIX}options SET option_value='http://localhost:${PORT}' WHERE option_name in ('home', 'siteurl');"
  fi

  echo 'Updating apache conf'

  sed -i s/:80/:$PORT/ /etc/apache2/sites-available/*.conf
  sed -i s/:443/:$SSL_PORT/ /etc/apache2/sites-available/*.conf
  sed -i s/80/$PORT/ /etc/apache2/ports.conf
  sed -i s/443/$SSL_PORT/ /etc/apache2/ports.conf

  touch /src/.initialized
fi

if [ "$RESET_ADMIN" == "1" ]; then
  mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "UPDATE ${PREFIX}users SET user_login='admin', user_pass=MD5('changeme') WHERE id=1;"
fi

exec apache2-foreground