#!/bin/bash
set -e

# Set input parameters
USERNAME="$1"
PASSWORD="$2"
DOMAIN="$3"
TOKEN="$4"

# === Setup Mosquitto ===
echo "[*] Configuring Mosquitto..."

# Crea il file delle password MQTT
mosquitto_passwd -b -c /etc/mosquitto/passwd "$USERNAME" "$PASSWORD"

# Crea i certificati TLS
cd /etc/mosquitto/certs
openssl req -new -x509 -days 365 -nodes \
  -out mosquitto.crt -keyout mosquitto.key \
  -subj "/C=IT/ST=Italy/L=Home/O=MQTT/CN=$DOMAIN.duckdns.org"

chmod 600 mosquitto.key

# Configura Mosquitto
cat <<EOF > /etc/mosquitto/conf.d/mqtt_secure.conf
listener 8883
cafile /etc/mosquitto/certs/mosquitto.crt
certfile /etc/mosquitto/certs/mosquitto.crt
keyfile /etc/mosquitto/certs/mosquitto.key
require_certificate false
password_file /etc/mosquitto/passwd
allow_anonymous false

listener 1883
password_file /etc/mosquitto/passwd
allow_anonymous false
EOF

# === Setup DuckDNS ===
echo "[*] Setting DuckDNS..."

cat <<EOF > /duckdns/duck.sh
#!/bin/bash
echo url="https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip=" | curl -k -o /duckdns/duck.log -K -
EOF

chmod 700 /duckdns/duck.sh

# Aggiungi il job al cron
echo "*/5 * * * * /duckdns/duck.sh >/dev/null 2>&1" > /etc/cron.d/duckdns
chmod 0644 /etc/cron.d/duckdns

# Necessario per cron
touch /var/log/cron.log

echo "[*] Setup completed successfully"
