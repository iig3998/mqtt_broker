#!/bin/bash

set -e

# Setup duckdns
echo "[*] Setup DuckDNS..."

mkdir -p ~/duckdns
cat <<EOF > ~/duckdns/duck.sh
echo url="https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip=" | curl -k -o ~/duckdns/duck.log -K -
EOF

chmod 700 ~/duckdns/duck.sh

(crontab -l 2>/dev/null; echo "*/5 * * * * ~/duckdns/duck.sh >/dev/null 2>&1") | crontab -

echo "[*] Done"

exit 0
