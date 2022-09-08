FROM ubuntu:22.04 as builder

ENV USER hostfactor

ENV GROUP hostfactor

ENV GID 1000

ENV UID 1000

STOPSIGNAL SIGTERM

RUN groupadd -g $GID $GROUP && \
    useradd -u $UID -g $GROUP -s /bin/sh -m $USER

RUN apt-get update && \
    apt-get install -y \
    wget \
    locales \
    software-properties-common

RUN add-apt-repository multiverse

RUN dpkg --add-architecture i386

## Add steamcmd
RUN echo steam steam/question select "I AGREE" | debconf-set-selections  && echo steam steam/license note '' | debconf-set-selections

RUN apt-get update && apt install -y  \
    lib32gcc-s1  \
    steamcmd

# Add unicode support
RUN locale-gen en_US.UTF-8
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'

RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

USER $USER:$GROUP

RUN steamcmd \
    +force_install_dir $HOME  \
    +login anonymous  \
    +app_info_update 1  \
    +app_update 258550 validate  \
    +quit

EXPOSE 28015/udp

ENV SERVER_IDENTITY "host_factor_server"

LABEL org.opencontainers.image.description="Rust Linux version ${VERSION}. See changelog here: ${VERSION_URL}."
LABEL org.opencontainers.image.url='ghcr.io/hostfactor/rust-server'
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.authors='eddie@hostfactor.io'

ENV HOME /home/$USER

WORKDIR $HOME

COPY --chown=$UID:$GID entrypoint.sh entrypoint.sh

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/RustDedicated_Data/Plugins/x86_64

ENTRYPOINT ["./entrypoint.sh"]
