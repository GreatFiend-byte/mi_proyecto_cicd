#!/bin/bash

# Script de despliegue
set -e

echo "🚀 Iniciando despliegue..."

# Variables
CONTAINER_NAME="mi-app-cicd"
IMAGE_NAME="mi-app-cicd:latest"

# Detener y eliminar contenedor anterior
echo "🛑 Deteniendo contenedor anterior..."
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

# Limpiar imágenes antiguas
echo "🧹 Limpiando imágenes antiguas..."
docker image prune -f

# Ejecutar nuevo contenedor
echo "🐳 Iniciando nuevo contenedor..."
docker run -d \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    -p 80:80 \
    $IMAGE_NAME

echo "✅ Despliegue completado exitosamente!"
echo "🌐 La aplicación está disponible en: http://$(curl -s ifconfig.me)"

# Verificar estado
sleep 5
docker ps --filter "name=$CONTAINER_NAME"