#!/bin/bash

# Функция для обновления системы и установки пакетов
function install_packages() {
    echo "Updating package list..."
    apt-get update -y

    echo "Installing required packages..."
    apt-get install -y \
        baobab \
        terminator \
        build-essential \
        libssl-dev \
        git \
        openvpn \
        easy-rsa \
        postgresql \
        vim \
        x11-apps \
        traceroute \
        curl \
        snapd \
        apt-transport-https \
        ca-certificates \
        software-properties-common

    echo "Packages installed successfully."
}

# Установка приложений через snap
function install_snap_packages() {
    echo "Installing snap packages..."
    snap install iputils
    snap install chromium-browser
    snap install code --classic
    snap install atom-fusion --beta

    echo "Snap packages installed successfully."
}

# Установка Docker
function install_docker() {
    echo "Setting up Docker repository and installing Docker..."
    
    # Установка Docker GPG ключа
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    
    # Добавление Docker репозитория
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # Обновление списка пакетов и установка Docker
    apt-get update -y
    apt-get install -y docker-ce

    echo "Docker installed successfully."

    # Настройка Docker прав для пользователя
    echo "Configuring Docker permissions..."
    groupadd docker
    usermod -aG docker $USER
    newgrp docker

    # Проверка Docker установки
    docker run hello-world

    # Изменение прав для .docker
    chown "$USER":"$USER" /home/"$USER"/.docker -R
    chmod g+rwx "$HOME/.docker" -R

    # Включение Docker сервисов
    systemctl enable docker.service
    systemctl enable containerd.service

    echo "Docker configured successfully."
}

# Установка NVIDIA Docker
function install_nvidia_docker() {
    echo "Setting up NVIDIA Docker..."
    # Установка ключа NVIDIA Docker
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    
    # Определение версии дистрибутива и добавление репозитория
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

    # Обновление списка пакетов и установка NVIDIA Docker
    apt-get update -y
    apt-get install -y nvidia-docker2

    # Перезапуск Docker для NVIDIA
    sudo pkill -SIGHUP dockerd

    echo "NVIDIA Docker installed successfully."
}

# Установка PGAdmin
function install_pgadmin() {
    echo "Setting up PGAdmin..."

    # Добавление ключа PGAdmin
    curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add -
    
    # Добавление репозитория для PGAdmin
    sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'
    
    # Обновление и установка PGAdmin
    apt-get update -y
    apt-get install -y pgadmin4

    echo "PGAdmin installed successfully."
}

# Установка Anydesk
function install_anydesk() {
    echo "Installing Anydesk..."

    if [ -f ~/nuvo_init/anydesk_6.3.3-1_amd64.deb ]; then
        dpkg -i ~/nuvo_init/anydesk_6.3.3-1_amd64.deb
        apt-get install -f  # Для разрешения зависимостей, если будут проблемы
        echo "Anydesk installed successfully."
    else
        echo "Anydesk package not found in ~/nuvo_init/."
    fi
}

# Основное выполнение скрипта
install_packages
install_snap_packages
install_docker
install_nvidia_docker
install_pgadmin
install_anydesk

echo "Script execution completed!"
