#!/usr/bin/env sh


if [ $(id -u) -ne 0 ]; then
  echo "Please run as root"
  exit
fi


set -e

# TODO: dont print echo stuff
set -o xtrace

echo "HPD-Lidar: setting up ROS sources"
sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

echo "HPD-Lidar: adding keys"
which curl &> /dev/null || apt install curl -y
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

echo "HPD-Lidar: updating repos"
apt update

echo "HPD-Lidar: installing ros noetic"
# TODO: check how bare bones we can get in the future
apt install ros-noetic-desktop-full

source /opt/ros/noetic/setup.bash

apt install python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential

rosdep init
rosdep update


hpd_catkin="${HPD_CATKIN_WS_DIR:-~/hpd_catkin_ws}"
echo "HPD-Lidar: using catkin ws directory: ${hpd_catkin}"
mkdir -p $hpd_catkin/src && cd $hpd_catkin/src

which git &> /dev/null || apt install git -y

git clone https://github.com/cartographer-project/cartographer_ros
git clone https://github.com/cartographer-project/cartographer
git clone https://github.com/slamtec/rplidar_ros
git clone https://github.com/Andrew-rw/gbot_core

cd ..

rosdep install --from-paths ./src --ignore-packages-from-source --rosdistro noetic -y

which ninja &> /dev/null || apt install ninja -y



catkin_make_isolated --install --use-ninja -DCMAKE_BUILD_TYPE=Release

echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
echo "source ${hpd_catkin}/install_isolated/setup.bash" >> ~/.bashrc
source ${hpd_catkin}/install_isolated/setup.bash
