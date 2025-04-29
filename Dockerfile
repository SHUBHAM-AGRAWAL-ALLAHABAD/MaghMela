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
      pdo_mysql \
      pdo_pgsql \
      mbstring \
      bcmath \
      zip \
 && rm -rf /var/cache/apk/*

# Composer binary
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 1) पहले पूरा PHP प्रोजेक्ट कॉपी करें
COPY . .

# 2) फिर node-builder से built assets को public/build में ओवरराइड करें
COPY --from=node-builder /app/public/build ./public/build

# Env फ़ाइल
RUN cp .env.example .env

# PHP dependencies & app key
RUN composer install --no-dev --optimize-autoloader --no-interaction \
 && php artisan key:generate --ansi --force

EXPOSE 10000

CMD ["sh","-c","php artisan migrate --force && php artisan config:cache && php artisan view:cache && php artisan serve --host=0.0.0.0 --port=${PORT}"]
