#!/bin/bash

# Nombre del archivo de salida
OUTPUT_FILE="/home/rayandolapapa/Documents/binbashlab/wifi/wifi_networks.csv"

# Interfaz de red en modo monitor (ejemplo: wlan0mon)
INTERFACE="wlxe84e0606d725"

# Duración de la captura en segundos
DURATION=30

# Función para iniciar airodump-ng y guardar la salida en un archivo temporal
function capture_networks() {
    airodump-ng --output-format csv --write /tmp/airodump_output $INTERFACE &
    PID=$!
    sleep $DURATION
    kill $PID
}

# Función para procesar el archivo de salida y extraer información única
function process_output() {
    # Procesar cada línea del archivo CSV de airodump-ng
    tail -n +2 /tmp/airodump_output-01.csv | grep -v "Station MAC" | while IFS=',' read -r bssid first_seen last_seen channel speed privacy cipher auth power beacons iv lan_ip id_length essid key
    do
        # Verificar si la MAC ya existe en el archivo de salida
        if ! grep -q "$bssid" $OUTPUT_FILE; then
            # Agregar la nueva entrada con la fecha actual
            echo "$(date +'%Y-%m-%d %H:%M:%S'),$bssid,$essid,$channel,$power,$privacy" >> $OUTPUT_FILE
        fi
    done
}

# Crear archivo de salida si no existe y agregar la cabecera
if [ ! -f $OUTPUT_FILE ]; then
    echo "Date,MAC,SSID,Channel,PWR,Encryption" > $OUTPUT_FILE
fi

# Bucle infinito para capturar y procesar redes continuamente
while true; do
    capture_networks
    process_output
    # Limpiar archivo temporal
    rm /tmp/airodump_output-01.csv
    sleep 5 # Esperar unos segundos antes de la próxima captura
done
