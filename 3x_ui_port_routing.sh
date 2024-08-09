#!/bin/bash

# wget -O 3x_ui_port_routing.sh https://raw.githubusercontent.com/tellusaflame/scripts/main/3x_ui_port_routing.sh
# chmod +x 3x_ui_port_routing.sh

# Создание файла /usr/local/bin/setup-iptables.sh
echo "Creating iptables setup script..."
sudo bash -c 'cat << EOF > /usr/local/bin/setup-iptables.sh
#!/bin/bash
iptables -t nat -A PREROUTING -i eth0 -p udp --dport 443 -j DNAT --to-destination fake_site_ip:443
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination fake_site_ip:80
EOF'

# Сделать файл исполняемым
echo "Making the iptables setup script executable..."
sudo chmod +x /usr/local/bin/setup-iptables.sh

# Создание файла /etc/systemd/system/setup-iptables.service
echo "Creating systemd service..."
sudo bash -c 'cat << EOF > /etc/systemd/system/setup-iptables.service
[Unit]
Description=Setup iptables rules
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/setup-iptables.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF'

# Активировать и запустить сервис
echo "Enabling and starting the setup-iptables service..."
sudo systemctl enable setup-iptables.service
sudo systemctl start setup-iptables.service

echo "Setup completed successfully!"
