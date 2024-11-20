const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

// Configuración
const OUTPUT_FILE = path.join(__dirname, 'wifi_networks.csv');
const LOG_FILE = path.join(__dirname, 'wificap.log');
const TMP_FILE = '/tmp/airodump_output-01.csv';
const INTERFACE = 'wlxe84e0606d725';
const DURATION = 30 * 1000; // Duración en milisegundos

// Crear archivo de salida si no existe y agregar la cabecera
if (!fs.existsSync(OUTPUT_FILE)) {
  fs.writeFileSync(OUTPUT_FILE, 'Date,MAC,SSID,Channel,PWR,Encryption\n');
}

// Función para iniciar airodump-ng y guardar la salida en un archivo temporal
function captureNetworks() {
  return new Promise((resolve, reject) => {
    const cmd = `sudo airodump-ng --output-format csv --write /tmp/airodump_output ${INTERFACE}`;
    const airodump = exec(cmd, (error) => {
      if (error) {
        fs.appendFileSync(LOG_FILE, `Error: ${error.message}\n`);
        return reject(error);
      }
      resolve();
    });

    setTimeout(() => {
      exec(`sudo kill ${airodump.pid}`, (error) => {
        if (error) {
          fs.appendFileSync(LOG_FILE, `Error stopping airodump-ng: ${error.message}\n`);
          return reject(error);
        }
        resolve();
      });
    }, DURATION);
  });
}

// Función para procesar el archivo de salida y extraer información única
function processOutput() {
  if (fs.existsSync(TMP_FILE)) {
    const data = fs.readFileSync(TMP_FILE, 'utf-8');
    const lines = data.split('\n').slice(1); // Omitir la primera línea (cabecera)
    
    lines.forEach(line => {
      if (!line.includes('Station MAC')) {
        const fields = line.split(',');
        const [bssid, , , channel, , , , , power, , , , , essid] = fields;

        if (!bssid) return;

        // Verificar si la MAC ya existe en el archivo de salida
        const existingData = fs.readFileSync(OUTPUT_FILE, 'utf-8');
        if (!existingData.includes(bssid)) {
          const newLine = `${new Date().toISOString()},${bssid},${essid},${channel},${power}\n`;
          fs.appendFileSync(OUTPUT_FILE, newLine);
        }
      }
    });

    // Eliminar el archivo temporal después de procesarlo
    fs.unlinkSync(TMP_FILE);
  } else {
    fs.appendFileSync(LOG_FILE, `Archivo temporal ${TMP_FILE} no encontrado.\n`);
  }
}

// Bucle infinito para capturar y procesar redes continuamente
(async function main() {
  while (true) {
    try {
      await captureNetworks();
      processOutput();
    } catch (error) {
      fs.appendFileSync(LOG_FILE, `Error: ${error.message}\n`);
    }
    await new Promise(resolve => setTimeout(resolve, 5000)); // Esperar unos segundos antes de la próxima captura
  }
})();
