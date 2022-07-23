FROM ubuntu:20.04

ENV TZ=American/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV DEBIAN_FRONTEND=noninteractive

RUN \
  apt update && \
  apt upgrade -y && \
  apt install -y sudo

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

ADD ./install.sh install.sh
RUN sudo bash install.sh

CMD ["roslaunch", "gbot_core", "gbot.launch"]
