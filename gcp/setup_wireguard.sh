#!/bin/bash
set -e

SERVER_WG_NIC="wg0"
SERVER_WG_IPV4="10.66.66.1"
SERVER_PORT="51820"
CLIENT_WG_IPV4="10.66.66.2"

echo "Updating packages and installing WireGuard..."
sudo apt-get update -y
sudo apt-get install -y wireguard qrencode

SERVER_PUB_IP=$(curl -s -4 ifconfig.me)
NIC=$(ip -4 route ls | grep default | awk '{print $5}' | head -1)

echo "Detected public IP: $SERVER_PUB_IP"
echo "Detected network interface: $NIC"

mkdir -p /etc/wireguard
cd /etc/wireguard
umask 077

# Generate server keys
wg genkey | tee server_private.key | wg pubkey > server_public.key
SERVER_PRIV_KEY=$(cat server_private.key)
SERVER_PUB_KEY=$(cat server_public.key)

# Generate client keys
wg genkey | tee client_private.key | wg pubkey > client_public.key
CLIENT_PRIV_KEY=$(cat client_private.key)
CLIENT_PUB_KEY=$(cat client_public.key)

cat > /etc/wireguard/${SERVER_WG_NIC}.conf << EOF
[Interface]
Address = ${SERVER_WG_IPV4}/24
ListenPort = ${SERVER_PORT}
PrivateKey = ${SERVER_PRIV_KEY}
PostUp = iptables -A FORWARD -i ${SERVER_WG_NIC} -j ACCEPT; iptables -t nat -A POSTROUTING -o ${NIC} -j MASQUERADE
PostDown = iptables -D FORWARD -i ${SERVER_WG_NIC} -j ACCEPT; iptables -t nat -D POSTROUTING -o ${NIC} -j MASQUERADE

[Peer]
PublicKey = ${CLIENT_PUB_KEY}
AllowedIPs = ${CLIENT_WG_IPV4}/32
EOF

echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo systemctl enable wg-quick@${SERVER_WG_NIC}
sudo systemctl start wg-quick@${SERVER_WG_NIC}

# Build client config
cat > /etc/wireguard/client.conf << EOF
[Interface]
PrivateKey = ${CLIENT_PRIV_KEY}
Address = ${CLIENT_WG_IPV4}/32
DNS = 1.1.1.1

[Peer]
PublicKey = ${SERVER_PUB_KEY}
Endpoint = ${SERVER_PUB_IP}:${SERVER_PORT}
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

echo ""
echo "========================================"
echo "ГОТОВО! WireGuard запущен."
echo "========================================"
echo "Статус сервера:"
sudo wg show
echo ""
echo "Конфиг для телефона сохранён в /etc/wireguard/client.conf"
echo "QR-код для сканирования приложением WireGuard на iPhone:"
echo ""
qrencode -t ansiutf8 < /etc/wireguard/client.conf
echo ""
echo "Текст конфига (если QR не сканируется):"
cat /etc/wireguard/client.conf
