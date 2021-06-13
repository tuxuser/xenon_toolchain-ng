FROM free60/ct-ng_toolchain_builder:latest

RUN useradd -ms /bin/bash xenonuser
USER xenonuser

WORKDIR /tmp/toolchain_build

# Copy crosstool-ng files
COPY ct-ng_config .
COPY patches patches

RUN cp ct-ng_config .config

# Build toolchain
RUN ct-ng build || (echo ":: build.log ::"; cat build.log; exit 1)
