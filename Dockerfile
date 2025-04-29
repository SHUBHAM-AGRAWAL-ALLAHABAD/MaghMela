# -----------------------
# 1) Node stage: build assets
# -----------------------
FROM node:18-alpine AS node-builder
WORKDIR /app

# केवल package.json, vite.config.js, resources फ़ोल्डर copy करें
COPY package.json package-lock.json vite.config.js ./
COPY resources resources

# Install & build
RUN npm ci \
 && npm run build

# -----------------------
# 2) PHP stage: run app
# -----------------------
FROM php:8.2-cli-alpine

WORKDIR /app
# 2) Install system deps + PHP extensions
RUN apk update \
 && apk add --no-cache \
      git \
      zip \
      unzip \
      libzip-dev \
      oniguruma-dev \
      postgresql-dev          \
 && docker-php-ext-install \
      pdo_mysql \
      pdo_pgsql \            # ← जोड़ा
      mbstring \
      bcmath  \
      zip \
 && rm -rf /var/cache/apk/*


# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy built assets from node-builder
COPY --from=node-builder /app/public/build public/build

# अब बाकि सारा PHP project copy करें
COPY . .

# Env
RUN cp .env.example .env

# PHP deps, key & cache
RUN composer install --no-dev --optimize-autoloader --no-interaction \
 && php artisan key:generate --ansi --force

EXPOSE 10000

CMD ["sh","-c","set -e; \
    echo 'Migrating...'; php artisan migrate --force; \
    echo 'Caching config/views...'; php artisan config:cache && php artisan view:cache; \
    echo 'Starting server...'; exec php artisan serve --host=0.0.0.0 --port=${PORT}"]
