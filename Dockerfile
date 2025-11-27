# Imagen base de Node
FROM node:18-alpine

# Carpeta de trabajo dentro del contenedor
WORKDIR /app

# Copiamos package.json y package-lock.json (si existe)
COPY package*.json ./

# Instalamos solo dependencias de producción
RUN npm install --production

# Copiamos el resto del proyecto (index.html, server.js, etc.)
COPY . .

# Exponemos el puerto donde corre Express
EXPOSE 3000

# Comando para arrancar la app
CMD ["npm", "start"]