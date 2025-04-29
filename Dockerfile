# 1) Alpine-base PHP 8.1 CLI
FROM php:8.1-cli-alpine

# 2) वर्किंग डायरेक्टरी
WORKDIR /app

# 3) सिस्टम डिप्स इंस्टॉल करो
RUN apk update \
 && apk add --no-cache \
    git \
    zip \
    unzip \
    libzip-dev \
    oniguruma-dev \
 && docker-php-ext-install \
    pdo_mysql \
    mbstring \
    bcmath \
    zip \
 && rm -rf /var/cache/apk/*

# 4) Composer binary copy from official composer image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 5) Composer dependencies (cache leverage के लिए)
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction

# 6) बाकी का कोड कॉपी करो
COPY . .

# 7) Laravel cache & key gen
RUN php artisan key:generate --ansi --force \
 && php artisan config:cache \
 && php artisan route:cache \
 && php artisan view:cache

# 8) Port exposição (DOCUMENTATION only)
EXPOSE 10000

# 9) Serve on whatever ${PORT} Render सेट करता है
CMD ["sh", "-c", "php artisan serve --host=0.0.0.0 --port=${PORT}"]
