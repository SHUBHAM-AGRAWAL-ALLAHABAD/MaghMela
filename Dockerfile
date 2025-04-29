# Use PHP 8.1 CLI
FROM php:8.1-cli

# Set working dir
WORKDIR /app

# Install system deps & PHP extensions
RUN apt-get update \
 && apt-get install -y zip unzip git \
 && docker-php-ext-install pdo_mysql mbstring bcmath

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy only composer files & install deps (leverages caching)
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of your code
COPY . .

# Generate app key & cache config/routes/views
RUN php artisan key:generate --ansi --force \
 && php artisan config:cache \
 && php artisan route:cache \
 && php artisan view:cache

# Expose Laravel’s dev server port
EXPOSE 10000

# Start Laravel’s built-in server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=10000"]
