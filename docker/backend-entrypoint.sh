#!/bin/sh
set -e

cd /var/www/html

# создать директории Laravel если их нет
mkdir -p storage/logs
mkdir -p bootstrap/cache

# исправить права
chown -R app:app storage bootstrap/cache || true
chmod -R 775 storage bootstrap/cache || true

# если нет .env
if [ ! -f .env ]; then
  cp .env.development .env
fi

# если нет ключа
if ! grep -q APP_KEY .env; then
  php artisan key:generate
fi

php artisan migrate --force

exec php artisan serve --host=0.0.0.0 --port=8000