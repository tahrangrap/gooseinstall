#!/bin/bash

set -e

echo "🚀 Installing GooseRelayVPN..."

cd /root

echo "📥 Downloading..."
wget -q https://github.com/Kianmhz/GooseRelayVPN/releases/download/v1.5.0/GooseRelayVPN-server-v1.5.0-linux-amd64.tar.gz

echo "📦 Extracting..."
tar -xzf GooseRelayVPN-server-v1.5.0-linux-amd64.tar.gz

cd GooseRelayVPN-server-v1.5.0-linux-amd64


chmod +x goose-server

echo "🔑 Generating tunnel key..."
TUNNEL_KEY=$(openssl rand -hex 32)

echo "⚙️ Creating config..."
cat <<EOF > server_config.json
{
  "server_host": "0.0.0.0",
  "server_port": 8443,
  "tunnel_key": "$TUNNEL_KEY",
  "upstream_proxy": "socks5://127.0.0.1:64588",
  "debug_timing": false
}
EOF


echo "🛠 Creating systemd service..."
cat <<EOF > /etc/systemd/system/goose-relay.service
[Unit]
Description=GooseRelayVPN exit server
After=network.target

[Service]
Type=simple
WorkingDirectory=/root/GooseRelayVPN-server-v1.5.0-linux-amd64
ExecStart=/root/GooseRelayVPN-server-v1.5.0-linux-amd64/goose-server -config /root/GooseRelayVPN-server-v1.5.0-linux-amd64/server_config.json
Restart=always
RestartSec=3
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF


echo "🔄 Reloading systemd..."
systemctl daemon-reload


systemctl enable goose-relay
systemctl start goose-relay


echo "📊 Service status:"
systemctl status goose-relay --no-pager

echo ""
echo "✅ DONE"
echo "-----------------------------------"
echo "🔑 TUNNEL KEY: $TUNNEL_KEY"
echo "🌐 TUNNEL URL: http://SERVER_IP:8443/tunnel"
echo "-----------------------------------"
