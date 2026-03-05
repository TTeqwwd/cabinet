# ============================================
# Development Stage
# ============================================
FROM php:8.4-cli-alpine AS development

WORKDIR /var/www/html

# System dependencies
RUN apk add --no-cache \
    git curl bash libpng-dev libjpeg-turbo-dev freetype-dev \
    postgresql-dev zip unzip zlib-dev oniguruma-dev \
    autoconf g++ make pkgconfig

# PHP extensions
RUN docker-php-ext-configure gd \
        --with-freetype=/usr/include/freetype2 \
        --with-jpeg=/usr/include \
 && docker-php-ext-install -j$(nproc) \
    pdo_pgsql mbstring gd bcmath opcache \
 && apk del autoconf g++ make pkgconfig

# Non-root user (UID matches host)
RUN addgroup -g 1000 app \
 && adduser -D -u 1000 -G app app

# Switch to non-root user
USER 1000

# Expose dev server port
EXPOSE 8000

# Command: artisan serve for dev
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]

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