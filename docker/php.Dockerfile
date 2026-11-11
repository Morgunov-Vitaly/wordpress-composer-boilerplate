FROM php:8.3.36-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip \
    && docker-php-ext-install mysqli \
    && a2enmod rewrite \
    && sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2.8.12 /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html
