FROM nginx:alpine

# Копируем конфигурацию nginx
COPY docker/nginx/nginx.prod.conf /etc/nginx/conf.d/default.conf

# Копируем файлы фронтенда из образа сборки
COPY --from=cabinet-frontend /app/dist /usr/share/nginx/html

EXPOSE 80
