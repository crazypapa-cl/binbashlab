#!/bin/bash

# Función para verificar la instalación de Aircrack-ng
check_aircrack() {
  command -v aircrack-ng >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "Aircrack-ng ya está instalado."
  else
    echo "Instalando Aircrack-ng..."
    sudo apt update
    sudo apt install aircrack-ng
  fi
}

# Llamada a la función para verificar e instalar
check_aircrack

# Adaptador de red a monitorear
interface="wlxe84e0606d725"

# Función para verificar el modo y cambiar si es necesario
check_mode() {
  iwconfig $interface | grep Mode: > /dev/null
  if [ $? -eq 0 ]; then
    echo "$interface está en modo normal. Cambiando a modo monitor..."
    sudo airmon-ng start $interface
  else
    echo "$interface ya está en modo monitor."
  fi
}

# Ejecutar la función cada X segundos (ajusta el tiempo según tus necesidades)
while true; do
  check_mode
  sleep 10
done