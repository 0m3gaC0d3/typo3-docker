#==========================================================
# TYPO3 87 (PHP 7.0, Apache)
#==========================================================
# Image: php:7.0-apache
#==========================================================
FROM php:7.0-apache
# Build custom image.
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
        curl \
        libfreetype6-dev \
        libxml2-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        zlib1g-dev \
        graphicsmagick \
	# Install PHP extensions.
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        zip \
        opcache \
        soap \
        pdo_mysql \
    && pecl install apcu \
    && pecl install xdebug \
    && docker-php-ext-enable apcu \
    && docker-php-ext-enable xdebug \
    # Add composer.
	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
	# Configure apache.
	&& a2enmod rewrite
# Add custom php.ini.
ADD ./.build/87/php.ini /usr/local/etc/php/conf.d/z99-additional-php.ini
# Add vhost.
ADD ./.build/87/vhost.conf /etc/apache2/sites-enabled/000-default.conf
# Add composer.json.
ADD ./.build/87/composer.json /var/www/composer.json
# Install TYPO3 87.
RUN cd /var/www \
    && composer install \
    && cd html \
    && touch FIRST_INSTALL \
    && chown -R www-data:www-data .
# Clean up.
RUN apt-get clean \
    && apt-get -y purge \
        curl \
        libfreetype6-dev \
        libxml2-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* /usr/src/*
# Configure volumes.
VOLUME /var/www/html/fileadmin
VOLUME /var/www/html/typo3conf
VOLUME /var/www/html/uploads