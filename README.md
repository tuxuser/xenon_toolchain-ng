# Usage

## Install dependencies

Example for debian

```
apt install -y \
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
```

## Clone the repository

To clone including git submodules, clone the repo likes this

```
git clone --recursive https://github.com/tuxuser/xenon_toolchain-ng
cd xenon_toolchain-ng/
```

## Install crosstool-ng

```
cd crosstool-ng/
./bootstrap
./configure --enable-local
make
cd ..
```

## Init crosstool-ng config and build

```
cp ct-ng_config .config
./crosstool-ng/ct-ng build
```