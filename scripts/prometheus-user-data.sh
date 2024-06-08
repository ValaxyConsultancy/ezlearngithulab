#!/bin/bash
# Update package list and install necessary packages
sudo apt update
sudo apt install -y wget tar

# Download Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.39.1/prometheus-2.39.1.linux-amd64.tar.gz

# Extract Prometheus
tar xvfz prometheus-2.39.1.linux-amd64.tar.gz
cd prometheus-2.39.1.linux-amd64

# Move Prometheus binaries to /usr/local/bin
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/

# Create necessary directories
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

# Move configuration files and directories
sudo mv consoles /etc/prometheus
sudo mv console_libraries /etc/prometheus
sudo mv prometheus.yml /etc/prometheus

# Create Prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

# Set ownership of Prometheus files and directories
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# Create systemd service file for Prometheus
sudo bash -c 'cat <<EOT > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file /etc/prometheus/prometheus.yml \\
    --storage.tsdb.path /var/lib/prometheus/ \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOT'

# Reload systemd to apply the new service file
sudo systemctl daemon-reload

# Enable and start Prometheus service
sudo systemctl enable prometheus
sudo systemctl start prometheus
