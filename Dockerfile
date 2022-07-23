FROM ubuntu:20.04
RUN \
  apt update && \
  apt upgrade -y && \

ARG USER=pi
RUN useradd -m -s --disabled-password /bin/bash $USER
RUN usermod -aG sudo $USER
RUN usermod -aG plugdev $USER
RUN netdev -aG plugdev $USER
RUN usermod -aG dialout $USER
RUN chsh -s /usr/bin/bash $USER

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
/etc/sudoers

USER $USER
WORKDIR /home/$USER

ADD ./install.sh
RUN sudo bash install.sh

CMD ["roslaunch", "gbot_core", "gbot.launch"]
