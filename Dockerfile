FROM node:22-alpine

WORKDIR /app

# Dependencias
COPY package*.json ./
RUN npm ci --only=production

# Código fuente
COPY src/ ./src/

EXPOSE 3000

CMD ["node", "src/index.js"]
