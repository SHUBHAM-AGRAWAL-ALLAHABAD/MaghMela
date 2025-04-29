# Use PHP 8.2 CLI on Alpine
FROM php:8.2-cli-alpine

# 1) Set working dir
WORKDIR /app

# 2) Install system deps + PHP extensions
RUN apk update \
 && apk add --no-cache \
    git \
    zip \
    unzip \
    libzip-dev \
    oniguruma-dev \
 && docker-php-ext-install \
    pdo_mysql mbstring bcmath zip \
 && rm -rf /var/cache/apk/*

# 3) Install Composer binary
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4) Copy your entire project (including artisan, vendor stub, etc)
COPY . .
RUN cp .env.example .env




 # 5) Install PHP deps, generate key (लेकिन बिल्ड टाइम में कोई कैश नहीं बनाना)
RUN composer install --no-dev --optimize-autoloader --no-interaction \
&& php artisan key:generate --ansi --force


# 6) Document the port and start on whatever PORT Render injects
# … बाकी सब वैसा ही रहने दें …


# Expose for documentation
EXPOSE 10000

CMD ["sh", "-c",
  "php artisan migrate --force \
   && php artisan config:cache \
   && php artisan view:cache \
   && php artisan serve --host=0.0.0.0 --port=${PORT}"
]
