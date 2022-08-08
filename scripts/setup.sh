#!/usr/bin/env bash

set -e

if [ $(id -u) -ne 0 ]; then
  echo "Please run as root"
  exit
fi

user=${SUDO_USER:-${whoami}}

which git &> /dev/null || apt install git -y

git -C HPD-Lidar pull || git clone https://github.com/c-flew/HPD-Lidar
chmod +x HPD-Lidar/scripts/*.sh
chown -R "$user" HPD-Lidar

which uhubctl &> /dev/null || apt install uhubctl -y

apt install -y docker.io containerd runc

if search=$(awk -F= '/^NAME/{print $2}' /etc/os-release | grep -i "ubuntu"); then
  source /etc/os-release
  sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
  wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key -O- | apt-key add -
else
  apt install -y podman 
fi

apt update
apt install -y podman

usermod -aG docker $user
podman pull docker.io/hpdlidar/lidar:latest

systemctl disable docker
systemctl stop docker

systemctl disable containerd
systemctl stop containerd
