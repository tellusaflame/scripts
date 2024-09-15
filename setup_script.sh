#!/bin/bash

# bash <(wget -qO- https://raw.githubusercontent.com/tellusaflame/scripts/main/setup_script.sh)
# wget -O setup_script.sh https://raw.githubusercontent.com/tellusaflame/scripts/main/setup_script.sh
# chmod +x setup_script.sh

# Функция для выполнения команды с очисткой экрана и паузой
run_command() {
    eval "$1 > /dev/null 2>&1"  # Выполняем команду и скрываем вывод
    # echo "Нажмите любую клавишу для продолжения..."
    # read -n 1 -s  # Ожидаем нажатия клавиши
    # sleep 1  # Пауза на 1 секунду
}

clear

# Обновление компонентов системы
echo "Updating system components..."
run_command "sudo apt update && sudo apt upgrade -y"

# Установка git
echo "Installing Git..."
run_command "sudo apt-get install git -y"

# Установка Docker
echo "Installing Docker..."
run_command "curl -fsSL https://get.docker.com -o get-docker.sh"
run_command "sudo sh get-docker.sh"

# Установка Docker Compose
echo "Installing Docker Compose..."
run_command "sudo apt-get install docker-compose -y"

# Настройка SSH
echo "Configuring SSH..."
run_command "sudo bash -c 'echo \"Port 55555\nPasswordAuthentication no\nPubkeyAuthentication yes\nChallengeResponseAuthentication no\nPermitRootLogin yes\nUsePAM yes\n\" > /etc/ssh/sshd_config.d/tellus.conf'"

# Установка fail2ban
echo "Installing and configuring fail2ban..."
run_command "apt-get install -y fail2ban"

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

# Установка и настройка UFW
echo "Installing and configuring UFW..."
run_command "sudo apt -y install ufw"
run_command "sudo ufw default deny incoming"
run_command "sudo ufw default allow outgoing"
run_command "sudo ufw allow 55555"
run_command "sudo ufw allow 443"
run_command "sudo ufw allow 2053"

# Установка панели 3X-UI
echo "Installing 3X-UI panel..."
run_command "cd ~"
run_command "git clone https://github.com/MHSanaei/3x-ui.git"
run_command "cd 3x-ui"
run_command "git checkout v2.4.0"
run_command "docker compose up -d"

# Копирование скрипта для обновления 3X-UI, а также настройки UDP/TCP маскировки для VLESS
echo "Copying scripts - 3X-UI update & VLESS UDP/TCP masking..."
run_command "cd ~"
run_command "wget -O update_3x-ui.sh https://raw.githubusercontent.com/tellusaflame/scripts/main/update_3x-ui.sh"
run_command "wget -O 3x_ui_port_routing.sh https://raw.githubusercontent.com/tellusaflame/scripts/main/3x_ui_port_routing.sh"
run_command "chmod +x update_3x-ui.sh"
run_command "chmod +x 3x_ui_port_routing.sh"

run_command "sudo ufw enable"

echo "Setup completed successfully! Rebooting..."
run_command "sleep 5"

run_command "sudo reboot now"
