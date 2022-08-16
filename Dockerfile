FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN \
  apt update && \
  apt upgrade -y && \
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

ADD ./bin/hpdl-install install.sh
# TODO: make this cleaner
RUN su pi -c "sudo bash install.sh" && rm install.sh

RUN \
  sudo apt clean && \
  sudo apt autoclean && \
  sudo apt autoremove && \
  sudo rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash", "-c"]
CMD source /opt/ros/noetic/setup.bash && \
    source /opt/hpdlidar/setup.bash && \
    roslaunch gbot_core gbot.launch
