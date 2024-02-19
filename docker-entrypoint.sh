#!/bin/bash

if [ ! -f /opt/.initialized ]; then

  HOME="http://localhost"

  if [ "$APACHE_PORT" != "80" ]; then
    HOME="http://localhost:${APACHE_PORT}"
    sed -i s/:80/:$APACHE_PORT/ /etc/apache2/sites-available/*.conf
    sed -i s/80/$APACHE_PORT/ /etc/apache2/ports.conf
  fi

  # configure wordpress
  if [ ! -f /var/www/html/wp-config.php ]; then 
    cat wp-config-sample.php > wp-config.php
    sed -i s/localhost/$MYSQL_HOST/ wp-config.php
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
    echo "define( 'WP_HOME', '${HOME}' );" >> wp-config.php
    echo "define( 'WP_SITEURL', '${HOME}' );" >> wp-config.php
  fi

  touch /opt/.initialized
fi

exec apache2-foreground