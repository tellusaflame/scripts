#!/bin/bash

# wget -O unattended-upgrades.sh https://raw.githubusercontent.com/tellusaflame/scripts/main/unattended-upgrades.sh?token=GHSAT0AAAAAACRKUAKCQWDMVGP4RDYZOHNGZVWPR2A
# chmod +x unattended-upgrades.sh

# Проверка на запуск от имени суперпользователя
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите этот скрипт от имени суперпользователя (sudo)."
  exit 1
fi

# Установка unattended-upgrades
echo "Установка unattended-upgrades..."
apt update
apt install -y unattended-upgrades

# Настройка автоматического обновления
echo "Настройка unattended-upgrades..."

# Создание файла 20auto-upgrades, если он не существует
if [ ! -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
  echo "Создание файла /etc/apt/apt.conf.d/20auto-upgrades..."
  echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.d/20auto-upgrades
  echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
else
  echo "Файл /etc/apt/apt.conf.d/20auto-upgrades уже существует."
fi

# Редактирование файла 50unattended-upgrades
echo "Редактирование конфигурации unattended-upgrades..."
cat <<EOT >> /etc/apt/apt.conf.d/50unattended-upgrades

// Разрешенные источники обновлений
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}-security";
    // Добавьте другие источники, если это необходимо
    // "\${distro_id}:\${distro_codename}-updates";
    // "\${distro_id}:\${distro_codename}-proposed";
};
EOT

# Перезапуск службы unattended-upgrades
echo "Перезапуск службы unattended-upgrades..."
systemctl restart unattended-upgrades

# Проверка статуса службы
echo "Статус службы unattended-upgrades:"
systemctl status unattended-upgrades

echo "Настройка завершена! Unattended-upgrades установлен и настроен."
