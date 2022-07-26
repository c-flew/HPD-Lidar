#!/usr/bin/env bash

set -e

if [ $(id -u) -ne 0 ]; then
  echo "Please run as root"
  exit
fi

which git &> /dev/null || apt install git -y

git clone https://github.com/c-flew/HPD-Lidar
chmod +x HPD-Lidar/scripts/*.sh

which uhubctl &> /dev/null || apt install uhubctl -y

apt install -y docker.io containerd runc

source /etc/os-release
sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"

wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/xUbuntu_${VERSION_ID}/Release.key -O- | apt-key add -

apt update
apt install -y podman

docker pull hpdlidar/lidar:latest
