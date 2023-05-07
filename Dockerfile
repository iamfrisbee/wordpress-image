FROM php:7.4-apache as base

# set the default environment variables
ENV MYSQL_DATABASE wordpress
ENV MYSQL_USER wordpress
ENV MYSQL_PASSWORD iekalj4h2e3hi
ENV PREFIX wp_
ENV PORT 80
ENV SSL_PORT 443

ENV DEBIAN_FRONTEND noninteractive

# create directory for mysql database restores
RUN mkdir -p /src/db

# install WordPress Requirements
RUN apt-get update -y && \
  apt-get install -y sudo wget gettext imagemagick libmagickwand-dev pwgen libzip-dev make libssl-dev libghc-zlib-dev libcurl4-gnutls-dev libexpat1-dev unzip

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
  && docker-php-source delete


FROM base as mysql
RUN mkdir -p /src/mysql && \
  cd /src/mysql && \
  wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb && \
  apt install -y ./mysql-apt-config_0.8.22-1_all.deb && \
  apt-get update && apt-get install -y mysql-server

FROM mysql as git
RUN mkdir -p /src/git && \
  cd /src/git && \
  wget https://github.com/git/git/archive/refs/heads/master.zip && \
  unzip master.zip && \
  cd git-master && \
  make prefix=/usr/local all && \
  make prefix=/usr/local install

FROM git as wordpress
# set the working directory
WORKDIR /var/www/html

# copy needed files
COPY ./source/htaccess.txt .htaccess

# download wordpress
RUN wget -O wordpress.tar.gz https://wordpress.org/wordpress-6.2.tar.gz

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

FROM wordpress

# add the entry point file
COPY ./source/docker-entrypoint.sh /usr/local/bin/

# fix permissions
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# set the entry point
CMD ["docker-entrypoint.sh"]