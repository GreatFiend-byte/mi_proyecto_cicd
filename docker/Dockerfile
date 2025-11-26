# docker/Dockerfile
FROM nginx:alpine
# Copia el archivo de configuración de Nginx del contenedor
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Copia los archivos de la app al directorio de Nginx
COPY app/ /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]