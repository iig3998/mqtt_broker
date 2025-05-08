# MQTT Broker

## Description

These scripts install and configure an MQTT broker with support for both unencrypted communication on port 1883 and secure TLS communication on port 8883, enabling remote access from external networks.

## How to run and install without Dockerfile
./install_broker.sh
./install_ddns.sh


## How to build and run with docker image
```
docker build -t mqtt-with-duckdns \
  --build-arg USERNAME=myuser \
  --build-arg PASSWORD=mypass \
  --build-arg DOMAIN=mydomain \
  --build-arg TOKEN=myduckdnstoken \
  .
```

```
docker run -d --name mqtt-container \
  -p 1883:1883 -p 8883:8883 \
  mqtt-with-duckdns
```
