#### Installing Software ####
FROM ubuntu:20.04 AS Base

ARG INTERNAL_USER=user
ARG PASSWORD=password

ENV INTERNAL_USER=${INTERNAL_USER}
ENV FILE_DIR=docker

# install pkgs
RUN dpkg --add-architecture i386

# useful pkg for development
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git vim screen telnet tmux rsync sudo unzip usbutils wget x11-apps xorg xterm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# required pkg for running installer
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      autoconf build-essential expect gawk gcc-multilib libncurses5-dev libncursesw5-dev libtinfo5 libtool net-tools texinfo zlib1g-dev zlib1g:i386 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# required pkg for running vivado/vitis and its workaround
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      libgmp-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# desktop environment
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      fonts-ipafont-gothic fonts-ipafont-mincho ibus ibus-mozc language-pack-ja language-pack-ja-base xfce4 xrdp xvfb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
EXPOSE 3389

#### Global Settings ####
# set locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8 \
    LANGUAGE en_US:en \
    LC_ALL en_US.UTF-8
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && echo 'Asia/Tokyo' > /etc/timezone

# copy install scripts
RUN chmod go+rx /root
COPY ${FILE_DIR}/install.sh /root/install.sh
COPY ${FILE_DIR}/install_config.txt /root/install_config.txt
RUN chmod +x /root/install.sh
COPY ${FILE_DIR}/settings.sh /root/settings.sh
COPY ${FILE_DIR}/startxrdp.sh /usr/bin/startxrdp.sh

# setup window manager
RUN echo "startxfce4" > /etc/skel/.xsession

# add non-priviledge user
RUN useradd -ms /bin/bash ${INTERNAL_USER} && \
    echo ${INTERNAL_USER}:${PASSWORD} | chpasswd && \
    echo "${INTERNAL_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN cp /etc/skel/.xsession /home/${INTERNAL_USER}/.xsession && chown -R ${INTERNAL_USER} /home/${INTERNAL_USER}/.xsession

#### User Settings ####
# modify user .bashrc
USER ${INTERNAL_USER}
WORKDIR /home/${INTERNAL_USER}
RUN echo "source /root/settings.sh" >> /home/${INTERNAL_USER}/.bashrc

#### Finalize ####
USER root
COPY ${FILE_DIR}/entrypoint.sh /root/entrypoint.sh
ENTRYPOINT [ "bash", "/root/entrypoint.sh" ]
CMD ["/usr/bin/startxrdp.sh"]
