#!/bin/sh
set -e

cd /app

# Ждем PostgreSQL
until pg_isready -h postgres -p 5432; do
  echo "Waiting for Postgres..."
  sleep 1
done

# Применяем миграции и создаем таблицы кэша и сессий
php artisan migrate --force
php artisan cache:table || true
php artisan session:table || true

# Запуск очереди
exec php artisan queue:work database --sleep=3 --tries=3 --timeout=60