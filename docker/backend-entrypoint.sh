#!/bin/sh
set -e

cd /var/www/html

mkdir -p storage/logs bootstrap/cache
chmod -R 775 storage bootstrap/cache || true

# env
if [ ! -f .env ]; then
  cp .env.development .env
fi

# key
APP_KEY_VALUE=$(grep "^APP_KEY=" .env | cut -d '=' -f2)

if [ -z "$APP_KEY_VALUE" ]; then
  php artisan key:generate
fi

# sessions table
php artisan session:table || true

# migrations
php artisan migrate --force

exec php artisan serve --host=0.0.0.0 --port=8000