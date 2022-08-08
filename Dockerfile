FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN \
  apt update && \
  apt upgrade -y && \
  apt install -y sudo tzdata

ARG USER=pi
RUN useradd -m -s /usr/bin/bash $USER
RUN passwd -d $USER
RUN usermod -aG sudo $USER
RUN usermod -aG plugdev $USER
RUN usermod -aG dialout $USER

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
/etc/sudoers

USER $USER
WORKDIR /home/$USER

ADD ./scripts/install.sh install.sh
RUN su pi -c "sudo bash install.sh" # TODO: make this cleaner

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["source", "/opt/ros/noetic/setup.bash", "&&", "source", "/home/pi/hpd_catkin_ws/install/setup.bash", "&&", "roslaunch", "gbot_core", "gbot.launch"]
