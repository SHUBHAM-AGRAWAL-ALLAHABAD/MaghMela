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

# 2) Install system deps + PHP extensions (pdo_pgsql के लिए postgresql-dev ज़रूरी)
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

# 3) Composer binary
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4) Built assets from node-builder
COPY --from=node-builder /app/public/build public/build

# 5) बाकी का PHP project
COPY . .

# 6) Env फ़ाइल
RUN cp .env.example .env

# 7) PHP deps install, key generate
RUN composer install --no-dev --optimize-autoloader --no-interaction \
 && php artisan key:generate --ansi --force

# 8) पोर्ट और CMD
EXPOSE 10000
CMD ["sh","-c","php artisan migrate --force && php artisan config:cache && php artisan view:cache && php artisan serve --host=0.0.0.0 --port=${PORT}"]
