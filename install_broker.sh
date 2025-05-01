#!/bin/bash

set -e

# CONFIGURA QUI
USERNAME=""
PASSWORD=""
DOMAIN=""
TOKEN=""

# Install mosquitto
echo "[*] Install Mosquitto..."
sudo apt-get update
sudo apt-get install -y mosquitto mosquitto-clients openssl

# Create password file
echo "[*] Creazione utente MQTT..."
sudo mosquitto_passwd -c /etc/mosquitto/passwd $USERNAME <<EOF
$PASSWORD
$PASSWORD
EOF

# Create tls certificates
echo "[*] Generazione certificati self-signed..."
sudo mkdir -p /etc/mosquitto/certs
cd /etc/mosquitto/certs

sudo openssl req -new -x509 -days 365 -nodes \
  -out mosquitto.crt -keyout mosquitto.key \
  -subj "/C=IT/ST=Italy/L=Home/O=MQTT/CN=$DOMAIN.duckdns.org"

sudo chmod 600 mosquitto.key
sudo chown mosquitto: /etc/mosquitto/certs/*

# Configure mosquitto
echo "[*] Scrittura configurazione Mosquitto..."

cat <<EOF | sudo tee /etc/mosquitto/conf.d/mqtt_secure.conf

# Set tls port (TLS)
listener 8883
cafile /etc/mosquitto/certs/mosquitto.crt
certfile /etc/mosquitto/certs/mosquitto.crt
keyfile /etc/mosquitto/certs/mosquitto.key
require_certificate false
password_file /etc/mosquitto/passwd
allow_anonymous false

# Set LAN port
listener 1883
password_file /etc/mosquitto/passwd
allow_anonymous false
EOF

# Restart service
echo "[*] Restart mosquitto..."
sudo systemctl restart mosquitto
sudo systemctl enable mosquitto

exit 0
