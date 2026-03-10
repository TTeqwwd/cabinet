#!/bin/sh
set -e

cd /app

# Ждем PostgreSQL
until pg_isready -h postgres -p 5432; do
  echo "Waiting for Postgres..."
  sleep 1
done

# Миграции и таблицы
php artisan migrate --force
php artisan cache:table || true
php artisan session:table || true

# Запуск расписания
exec php artisan schedule:work