FROM php:8.2-apache

WORKDIR /var/www/html

# install dependencies
RUN apt-get update -y \
  && apt-get install -y wget libjpeg62-turbo-dev libpng-dev libfreetype-dev gettext \
  imagemagick libmagickwand-dev pwgen libzip-dev make libssl-dev libghc-zlib-dev \
  libcurl4-gnutls-dev libexpat1-dev unzip

# enable mod rewrite
RUN a2enmod rewrite

# install imagick pecl extension
RUN echo '' | pecl install imagick

# install php modules
RUN docker-php-source extract \
  && docker-php-ext-install exif \
  && docker-php-ext-install mysqli \
  && docker-php-ext-enable imagick \
  && docker-php-ext-install zip \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-source delete

# download wordpress
RUN wget https://wordpress.org/latest.zip \
  && unzip latest.zip \
  && mv wordpress/* ./ \
  && rmdir wordpress

# fix permissions
RUN chown -R www-data:www-data *

# add the entry point file
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# add the generic .htaccess
COPY ./htaccess.txt /var/www/html/.htaccess

# fix permissions
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# set the entry point
CMD ["docker-entrypoint.sh"]