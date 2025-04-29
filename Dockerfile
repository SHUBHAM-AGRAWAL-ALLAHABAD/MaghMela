# -----------------------
# 1) Node stage: build assets
# -----------------------
FROM node:18-alpine AS node-builder
WORKDIR /app

COPY package.json package-lock.json vite.config.js ./
COPY resources resources

RUN npm ci \
 && npm run build

# -----------------------
# 2) PHP stage: run app
# -----------------------
FROM php:8.2-cli-alpine

# ✅ Port for Railway
ENV PORT=10000

WORKDIR /app

RUN apk update \
 && apk add --no-cache \
      git \
      zip \
      unzip \
      libzip-dev \
      oniguruma-dev \
      postgresql-dev \
 && docker-php-ext-install \
      pdo_pgsql \
      mbstring \
      bcmath \
      zip \
 && rm -rf /var/cache/apk/*

# Composer binary
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ✅ Copy full Laravel project
COPY . .

# ✅ Override Vite build output
COPY --from=node-builder /app/public/build ./public/build

# ✅ Copy .env if needed
RUN cp .env.example .env

# ✅ Install PHP deps & generate key
RUN composer install --no-dev --optimize-autoloader --no-interaction \
 && php artisan key:generate --ansi --force

# ✅ Set folder permissions
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache

EXPOSE 10000

CMD ["sh", "-c", "php artisan migrate --force && php artisan config:cache && php artisan view:cache && php artisan serve --host=0.0.0.0 --port=${PORT}"]
