FROM nginx:alpine

# Copia tu index.html al directorio que Nginx sirve
COPY index.html /usr/share/nginx/html/index.html

# Expone el puerto 80 (Nginx lo usa por defecto)
EXPOSE 80

# Nginx ya viene configurado, no necesitas CMD custom