# Usar una imagen base de Nginx
FROM nginx:alpine

# Copiar archivos estáticos
COPY ../app /usr/share/nginx/html

# Copiar configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Exponer puerto
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]