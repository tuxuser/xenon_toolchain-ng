FROM ubuntu:21.04

# Install dependencies
RUN apt update && apt install -y \
    build-essential \
    autoconf \
    automake \
    bison \
    diffutils \
    flex \
    gawk \
    git \
    gperf \
    help2man \
    libncurses-dev \
    libtool-bin \
    make \
    patch \
    python-dev \
    texinfo \
    unzip \
    wget \
    xz-utils

WORKDIR /tmp/ct-ng_build
# Download && install crosstool-ng
COPY crosstool-ng crosstool-ng
RUN ls -alh
RUN cd crosstool-ng && \
        ./bootstrap && \
        ./configure && \
        make && \
        make install && \
        cd .. && \
        rm -rf crosstool-ng

RUN useradd -ms /bin/bash xenonuser
USER xenonuser
WORKDIR /tmp/toolchain_build

# Copy crosstool-ng files
COPY ct-ng_config .
COPY patches patches

RUN cp ct-ng_config .config

# Build toolchain
RUN ct-ng build