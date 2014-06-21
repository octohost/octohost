#!/bin/bash
#
NEW_IP="192.168.0.16"
START_JOIN="0.0.0.0"
CONSUL_NODE_NAME="consul-leader-1"

# Fix PUBLIC_IP
sed -i "8s/.*/PUBLIC_IP=\"$NEW_IP\"/" /etc/default/octohost
sed -i '31s/.*/EMAIL_NOTIFICATION=\"darron@froese\.org\"/' /etc/default/octohost

# Restart octo tentacles.
octo tentacles stop
octo tentacles start

# Allow other members of the cluster full access.
ufw allow from 192.168.0.0/24

# Fix the Consul config - stop it.
service consul stop
cat << EOF > /etc/consul/config.json
{
  "datacenter": "dc1",
  "data_dir": "/var/cache/consul",
  "log_level": "INFO",
  "node_name": "$CONSUL_NODE_NAME",
  "config_dir": "/etc/consul/config.d",
  "bind_addr": "0.0.0.0",
  "advertise_addr": "$NEW_IP",
  "domain": "consul.",
  "recursor": "8.8.8.8",
  "encrypt": "p4T1eTQtKji/Df3VrMMLzg==",
  "server": true,
  "bootstrap": true,
  "start_join": ["$START_JOIN"]
}
EOF

# Delete /var/cache/consul.
rm -rf /var/cache/consul/*

# Restart Consul.
service consul start

octo services:register
