#!/bin/bash

# bash <(wget -qO- https://raw.githubusercontent.com/tellusaflame/scripts/main/setup_script.sh)
# wget -O setup_script.sh https://raw.githubusercontent.com/tellusaflame/scripts/main/setup_script.sh
# chmod +x setup_script.sh

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

# Установка fail2ban
echo "Установка fail2ban..."
apt-get update
apt-get install -y fail2ban

# Путь к конфигурационному файлу jail.local
JAIL_LOCAL="/etc/fail2ban/jail.local"

# Проверка, существует ли jail.local, если нет - создаем его
if [ ! -f "$JAIL_LOCAL" ]; then
    echo "Создание файла $JAIL_LOCAL"
    touch "$JAIL_LOCAL"
fi

# Добавление конфигурации для sshd
cat <<EOL > "$JAIL_LOCAL"
[sshd]
enabled = true
port = 55555
filter = sshd
logpath = /var/log/auth.log  ; Путь к логам зависит от вашей системы
maxretry = 5
bantime = 86400
findtime = 3600
EOL

# Перезапуск fail2ban
echo "Перезапуск fail2ban..."
systemctl restart fail2ban

# Проверка статуса fail2ban
echo "Статус fail2ban для sshd:"
fail2ban-client status sshd


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
git checkout v2.4.0

# Запуск 3X-UI с помощью Docker Compose
echo "Starting 3X-UI with Docker Compose..."
docker compose up -d

# Перезапуск службы SSH для применения изменений
echo "Restarting SSH service..."
sudo systemctl restart ssh

# Копирование скрипта для обновления 3X-UI, а также настройки UDP/TCP маскировки для VLESS
cd ~
wget -O update_3x-ui.sh https://raw.githubusercontent.com/tellusaflame/scripts/main/update_3x-ui.sh
wget -O 3x_ui_port_routing.sh https://raw.githubusercontent.com/tellusaflame/scripts/main/3x_ui_port_routing.sh
chmod +x update_3x-ui.sh
chmod +x 3x_ui_port_routing.sh

echo "Setup completed successfully! Rebooting..."

sudo reboot now
