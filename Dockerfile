FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC 
RUN apt-get update -y && apt-get -y install tzdata

RUN apt -y update && apt -y upgrade

RUN apt install -y software-properties-common

RUN apt-add-repository ppa:ondrej/php

RUN apt update -y

RUN useradd -ms /bin/bash ubuntu

RUN apt -y install \
        apache2 \
        libapache2-mod-php \
        libapache2-mod-auth-openidc \
        php8.2-bcmath \
        php8.2-cli \
        php8.2-curl \
        php8.2-gd \
        php8.2-intl \
        php8.2-ldap \
	php8.2-pdo \
        php8.2-mbstring \
        php8.2-mysql \
        php8.2-pgsql \
        php8.2-soap \
        php8.2-tidy \
        php8.2-uploadprogress \
        php8.2-xmlrpc \
        php8.2-yaml \
        php8.2-zip \
        libcap2-bin && \
    setcap 'cap_net_bind_service=+ep' /usr/sbin/apache2 && \
    a2disconf other-vhosts-access-log && \
    # chown -Rh www-data. /var/run/apache2 && \
    chown -Rh ubuntu. /var/run/apache2 && \
    apt-get -y install --no-install-recommends imagemagick && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN    a2enmod rewrite headers expires ext_filter

# Override default apache and php config
COPY src/000-default.conf /etc/apache2/sites-available
COPY src/mpm_prefork.conf /etc/apache2/mods-available
COPY src/status.conf      /etc/apache2/mods-available
COPY src/99-local.ini     /etc/php/8.2/apache2/conf.d

COPY src/index.php /var/www/html

RUN rm -f /var/www/html/index.html && \
    mkdir /var/www/html/.config && \
    tar cf /var/www/html/.config/etc-apache2.tar etc/apache2 && \
    tar cf /var/www/html/.config/etc-php.tar     etc/php && \
    dpkg -l > /var/www/html/.config/dpkg-l.txt


RUN chown -R ubuntu: /var/www/html

WORKDIR /var/www/html
EXPOSE 80
# USER www-data
USER ubuntu

ENTRYPOINT ["apache2ctl", "-D", "FOREGROUND"]
