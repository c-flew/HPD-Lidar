FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN \
  apt update && \
  apt upgrade -y && \
  apt clean && \
  apt autoclean && \
  apt autoremove && \
  apt install -y sudo tzdata && \
  rm -rf /var/lib/apt/lists/*

ARG USER=pi
RUN \
  useradd -m -s /usr/bin/bash $USER && \
  passwd -d $USER && \
  usermod -aG sudo $USER && \
  usermod -aG plugdev $USER && \
  usermod -aG dialout $USER && \
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $USER
WORKDIR /home/$USER

ENV ROS_DISTRO noetic

ADD ./scripts/install.sh install.sh
RUN su pi -c "sudo bash install.sh" # TODO: make this cleaner

RUN \
  apt clean && \
  apt autoclean && \
  auto autoremove && \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["source", "/opt/ros/noetic/setup.bash", "&&", "source", "/home/pi/hpd_catkin_ws/install/setup.bash", "&&", "roslaunch", "gbot_core", "gbot.launch"]
