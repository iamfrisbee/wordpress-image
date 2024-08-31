# WordPress Image

This image can be used to quickly standup a wordpress site locally. A WordPress project that uses this image already exists [here](https://github.com/iamfrisbee/wordpress-project) if you need a quick setup.

## Mount directories

Mount the directories that are custom in your environment like plugins or themes to `/var/www/html`. For example, if you are trying to do theme development, you can mount your themes folder to `./themes:/var/www/html/wp-content/themes`

## Environment variables

All environment variables are optional and likely not needed if you are just developing locally.

Variable | Description | Default
--|--|--
MYSQL_HOST | host name for the mysql database instance | localhost
MYSQL_DATABASE | database name to use | wordpress
MYSQL_USER | username to connect to db | wordpress
MYSQL_PASSWORD | password to use to connect to db | iekalj4h2e3hi
PREFIX | WordPress table prefix | wp_
APACHE_PORT | HTTP port for Apache | 80
