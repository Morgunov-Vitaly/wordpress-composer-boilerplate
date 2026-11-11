FROM php:8.3.36-fpm

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip \
    && docker-php-ext-install mysqli \
    && git config --system --add safe.directory /var/www/html \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2.8.12 /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html
