#!/bin/bash

# --- CONFIGURACIÓN ---
BLUE_CONTAINER="app-blue"
GREEN_CONTAINER="app-green"
BLUE_PORT="8080"
GREEN_PORT="8081"
IMAGE_NAME="mi-proyecto-cicd:latest"
NGINX_CONF="/etc/nginx/conf.d/app_router.conf"
ACTIVE_ENV_FILE="/var/www/active_env.txt"

# --- LÓGICA DE CAMBIO DE ENTORNO ---
# Determina qué ambiente está activo y cuál será el objetivo del despliegue
if [ -f $ACTIVE_ENV_FILE ] && [ "$(cat $ACTIVE_ENV_FILE)" == "green" ]; then
    TARGET_ENV="blue"
else
    TARGET_ENV="green"
fi

if [ "$TARGET_ENV" == "blue" ]; then
    TARGET_CONTAINER=$BLUE_CONTAINER
    TARGET_PORT=$BLUE_PORT
    OTHER_CONTAINER=$GREEN_CONTAINER
else
    TARGET_CONTAINER=$GREEN_CONTAINER
    TARGET_PORT=$GREEN_PORT
    OTHER_CONTAINER=$BLUE_CONTAINER
fi

echo "--- Iniciando Despliegue Blue-Green ---" 
echo "Ambiente Objetivo (Deploy): $TARGET_ENV, Puerto: $TARGET_PORT"
echo "Ambiente Activo (Old): $OTHER_CONTAINER"

# 1. Construir la nueva imagen Docker
echo "1. Construyendo imagen $IMAGE_NAME..."
docker build -t $IMAGE_NAME -f docker/Dockerfile .

# 2. Detener y eliminar el contenedor objetivo si existe
echo "2. Deteniendo y eliminando contenedor viejo: $TARGET_CONTAINER"
docker stop $TARGET_CONTAINER 2>/dev/null
docker rm $TARGET_CONTAINER 2>/dev/null

# 3. Lanzar un nuevo contenedor con la nueva imagen
echo "3. Iniciando nuevo contenedor $TARGET_CONTAINER en el puerto $TARGET_PORT..."
docker run -d --name $TARGET_CONTAINER -p $TARGET_PORT:80 $IMAGE_NAME

# 4. Prueba de salud (Health Check)
echo "4. Esperando 10 segundos para Health Check..."
sleep 10
HEALTH_CHECK_URL="http://localhost:$TARGET_PORT"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_CHECK_URL)

if [ "$HTTP_CODE" == "200" ]; then
    echo "SUCCESS: Health check OK. HTTP $HTTP_CODE."
    
    # 5. ACTUALIZAR NGINX PRINCIPAL (el "CUT OVER")
    echo "5. Redirigiendo tráfico a $TARGET_ENV (Puerto $TARGET_PORT)..."
    
    # Escribe la nueva configuración de Nginx (apuntando al puerto del nuevo entorno)
    echo "server {
        listen 80;
        server_name _;
        location / {
            proxy_pass http://localhost:$TARGET_PORT;
        }
    }" | sudo tee $NGINX_CONF
    
    # 6. Recargar Nginx para aplicar el cambio instantáneo
    sudo nginx -s reload
    
    # 7. Actualizar el archivo de estado para el próximo despliegue
    echo "$TARGET_ENV" | sudo tee $ACTIVE_ENV_FILE

    echo "--- ¡Despliegue Blue-Green COMPLETO! Tráfico en $TARGET_ENV ---"

else
    echo "ERROR: Health check FALLIDO (HTTP $HTTP_CODE). Despliegue cancelado."
    # Si falla, eliminamos el contenedor roto y mantenemos el tráfico en el entorno antiguo.
    docker stop $TARGET_CONTAINER 2>/dev/null
    docker rm $TARGET_CONTAINER 2>/dev/null
    exit 1
fi