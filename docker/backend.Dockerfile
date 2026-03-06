# ============================================
# Development Stage
# ============================================
FROM php:8.4-cli-alpine AS development

WORKDIR /var/www/html

RUN apk add --no-cache \
    git curl bash libpng-dev libjpeg-turbo-dev freetype-dev \
    postgresql-dev zip unzip zlib-dev oniguruma-dev \
    autoconf g++ make pkgconfig

RUN docker-php-ext-configure gd \
        --with-freetype=/usr/include/freetype2 \
        --with-jpeg=/usr/include \
 && docker-php-ext-install -j$(nproc) \
    pdo_pgsql mbstring gd bcmath opcache \
 && apk del autoconf g++ make pkgconfig

COPY docker/backend-entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN addgroup -g 1000 app \
 && adduser -D -u 1000 -G app app

USER 1000

EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# ============================================
# Production Stage
# ============================================
FROM php:8.4-fpm-alpine AS production

WORKDIR /app

# System dependencies
RUN apk add --no-cache \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    postgresql-dev zip unzip \
    bash zlib-dev oniguruma-dev \
    autoconf g++ make pkgconfig

# PHP extensions
RUN docker-php-ext-configure gd \
        --with-freetype=/usr/include/freetype2 \
        --with-jpeg=/usr/include \
 && docker-php-ext-install -j$(nproc) \
    pdo_pgsql mbstring gd bcmath opcache \
 && apk del autoconf g++ make pkgconfig

# Non-root user (arbitrary UID)
RUN addgroup -g 10001 app \
 && adduser -D -u 10001 -G app app

# Copy source code
COPY . .

# Fix ownership
RUN chown -R app:app /app

# Set user
USER 10001

# Expose FPM
EXPOSE 9000

CMD ["php-fpm"]