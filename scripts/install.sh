#!/usr/bin/env bash


set -e

# TODO: dont print echo stuff
set -o xtrace


if [ $(id -u) -ne 0 ]; then
  echo "Please run as root"
  exit
fi

TMP_DF=$DEBIAN_FRONTEND
export DEBIAN_FRONTEND=noninteractive

which lsb_release &> /dev/null || apt install lsb-release -y
dpkg-query -l | grep build-essential || apt install -y build-essential

user=${SUDO_USER:-$(whoami)}

echo "HPD-Lidar: setting up ROS sources"
sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

echo "HPD-Lidar: adding keys"
which curl &> /dev/null || apt install curl -y
which git &> /dev/null || apt install git -y
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

echo "HPD-Lidar: updating repos"
apt update

echo "HPD-Lidar: installing ros noetic"
# TODO: check how bare bones we can get in the future
apt install -y ros-noetic-desktop

source /opt/ros/noetic/setup.bash

apt install -y python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential

[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ] && rosdep init
rosdep update


hpd_catkin="${HPD_CATKIN_WS_DIR:-/home/$user/hpd_catkin_ws}"
echo "HPD-Lidar: using catkin ws directory: ${hpd_catkin}"
mkdir -p $hpd_catkin/src && cd $hpd_catkin/src

which git &> /dev/null || apt install git -y

git -C cartographer pull || git clone https://github.com/cartographer-project/cartographer
git -C cartographer_ros pull || git clone https://github.com/cartographer-project/cartographer_ros
git -C rplidar_ros pull || git clone https://github.com/slamtec/rplidar_ros
git -C gbot_core pull || git clone https://github.com/Andrew-rw/gbot_core

cp rplidar_ros/scripts/rplidar.rules /etc/udev/rules.d
mkdir -p gbot_core/param

which ninja &> /dev/null || apt install ninja-build -y
which stow &> /dev/null || apt install stow -y
which cmake &> /dev/null || apt install cmake -y

cd ..
rm -rf abseil-cpp
sh src/cartographer/scripts/install_abseil.sh

apt install google-mock libgmock-dev -y

rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic -y -r
catkin_make_isolated --install --install-space ./install --use-ninja -DCMAKE_BUILD_TYPE=Release
cd ..


touch ~/.bashrc
grep -qxF "source /opt/ros/noetic/setup.bash" /home/$user/.bashrc || echo "source /opt/ros/noetic/setup.bash" >> /home/$user/.bashrc
grep -qx "source ${hpd_catkin}/install/setup.bash" /home/$user/.bashrc || echo "source ${hpd_catkin}/install/setup.bash" >> /home/$user/.bashrc
source ${hpd_catkin}/install/setup.bash

chown -R "$user" "$hpd_catkin"

which uhubctl &> /dev/null || apt install uhubctl -y
export DEBIAN_FRONTEND=$TMP_DF
