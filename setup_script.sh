#!/bin/bash

# Обновление компонентов системы
echo "Updating system components..."
sudo apt update && sudo apt upgrade -y

# Установка git
echo "Installing Git..."
sudo apt-get install git -y

# Установка Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Установка Docker Compose
echo "Installing Docker Compose..."
sudo apt-get install docker-compose -y

# Настройка SSH
echo "Configuring SSH..."
sudo bash -c 'echo "
Port 55555
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
PermitRootLogin yes
UsePAM yes
" > /etc/ssh/sshd_config.d/tellus.conf'

# Установка и настройка UFW
echo "Installing and configuring UFW..."
sudo apt -y install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 55555
sudo ufw allow 443
sudo ufw allow 2053
sudo ufw enable

# Установка панели 3X-UI
echo "Installing 3X-UI panel..."
cd ~
git clone https://github.com/MHSanaei/3x-ui.git
cd 3x-ui
git checkout v2.3.12

# Запуск 3X-UI с помощью Docker Compose
echo "Starting 3X-UI with Docker Compose..."
docker compose up -d

# Перезапуск службы SSH для применения изменений
echo "Restarting SSH service..."
sudo systemctl restart sshd

echo "Setup completed successfully!"
