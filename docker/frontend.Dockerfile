# ============================================
# Development Stage
# ============================================
FROM node:22-alpine AS development

WORKDIR /app

# Копируем package.json и package-lock.json
COPY package*.json ./

# Устанавливаем зависимости под пользователем node
RUN chown -R node:node /app

USER node
RUN npm install

# Копируем исходники под node (для dev bind mount это важно)
COPY --chown=node:node . .

EXPOSE 5173

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# ============================================
# Production Build Stage
# ============================================
FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci
COPY . .

# Создаём пользователя для безопасности в проде
RUN addgroup -g 1001 -S nodejs \
 && adduser -S nodejs -u 1001 -G nodejs \
 && chown -R nodejs:nodejs /app

USER nodejs
RUN npm run build

# ============================================
# Production Serve Stage (Nginx)
# ============================================
FROM nginx:1.25.4-alpine AS production

# Копируем собранные файлы
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.prod.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]