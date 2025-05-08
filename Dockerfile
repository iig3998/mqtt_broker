# Usa una base di Debian
FROM debian:bullseye

# ARG per passare variabili d'ambiente al momento della build
ARG USERNAME
ARG PASSWORD
ARG DOMAIN
ARG TOKEN

# Installa i pacchetti necessari
RUN apt-get update && \
    apt-get install -y mosquitto mosquitto-clients openssl curl cron && \
    mkdir -p /etc/mosquitto/certs /etc/mosquitto/conf.d /duckdns

# Copia ed esegui lo script di setup
COPY setup.sh /setup.sh
RUN chmod +x /setup.sh && /setup.sh "$USERNAME" "$PASSWORD" "$DOMAIN" "$TOKEN"

# Espone le porte MQTT
EXPOSE 1883 8883

# Volumi persistenti
VOLUME ["/etc/mosquitto/passwd", "/etc/mosquitto/certs", "/duckdns"]

# Avvia sia cron che mosquitto
CMD service cron start && mosquitto -c /etc/mosquitto/mosquitto.conf
