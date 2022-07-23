#!/usr/bin/env bash


set -e

# TODO: dont print echo stuff
set -o xtrace


if [ $(id -u) -ne 0 ]; then
  echo "Please run as root"
  exit
fi

user=$(logname)

echo "HPD-Lidar: setting up ROS sources"
sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

echo "HPD-Lidar: adding keys"
which curl &> /dev/null || apt install curl -y
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

which ninja &> /dev/null || apt install ninja-build -y

cd ..
#rm -rf abseil-cpp
#sh src/cartographer/scripts/install_abseil.sh

rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic -y -r
catkin_make_isolated --install --install-space --use-ninja ./install -DCMAKE_BUILD_TYPE=Release
cd ..






echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
echo "source ${hpd_catkin}/install_isolated/setup.bash" >> ~/.bashrc
source ${hpd_catkin}/install_isolated/setup.bash

chown -R "$user" "$hpd_catkin"
