FROM php:7.4-apache

LABEL version 0.1.0

# set the default environment variables
ENV MYSQL_DATABASE wordpress
ENV MYSQL_USER wordpress
ENV MYSQL_PASSWORD iekalj4h2e3hi

# open the port
EXPOSE 80

# install certbot requirements

# install WordPress Requirements
RUN apt-get update -y && apt-get install -y wget gettext imagemagick libmagickwand-dev pwgen libzip-dev

# install imagick pecl extension
RUN echo '' | pecl install imagick

# install php modules
RUN docker-php-source extract \
  && docker-php-ext-install exif \
  && docker-php-ext-install mysqli \
  && docker-php-ext-enable imagick \
  && docker-php-ext-install zip \
  && docker-php-source delete

# set the working directory
WORKDIR /var/www/html

# copy needed files
COPY htaccess.txt .htaccess
COPY docker-entrypoint.sh /usr/local/bin/

# fix permissions
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# download wordpress
RUN wget -O wordpress.tar.gz https://wordpress.org/latest.tar.gz

# extract wordpress
RUN tar -zxf wordpress.tar.gz --strip-components 1

# fix permissions
RUN chown -R www-data:www-data *

# delete the garbage
RUN rm wordpress.tar.gz \
  && rm readme.html \
  && rm wp-content/plugins/hello.php \
  && rm -Rf wp-content/plugins/akismet \
  && rm -Rf wp-content/themes/twentyseventeen \
  && rm -Rf wp-content/themes/twentynineteen

# enable mod rewrite
RUN a2enmod rewrite

# set the entry point
ENTRYPOINT ["docker-entrypoint.sh"]
