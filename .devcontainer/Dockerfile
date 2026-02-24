FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Yocto / OE build host dependencies
# https://docs.yoctoproject.org/ref-manual/system-requirements.html
RUN apt-get update && apt-get install -y --no-install-recommends \
    gawk wget git git-lfs diffstat unzip texinfo gcc g++ build-essential \
    chrpath socat cpio python3 python3-pip python3-pexpect python3-setuptools \
    xz-utils debianutils iputils-ping python3-git python3-jinja2 \
    libsdl1.2-dev pylint xterm python3-subunit mesa-common-dev \
    zstd liblz4-tool file locales tmux \
    # Networking & convenience
    curl ca-certificates sudo nano less rsync \
    # For ./scripts/create_sdcard_from_flashlayout.sh
    gdisk \
    # For fetch-vendor-bsp.sh
    jq \
    && rm -rf /var/lib/apt/lists/*

# Generate en_US.UTF-8 locale (required by bitbake)
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install oras CLI for pulling vendor BSP from GHCR
ARG ORAS_VERSION=1.3.0
RUN curl -fSL "https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_amd64.tar.gz" \
    | tar xz -C /usr/local/bin oras

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Yocto refuses to run as root — create a build user
ARG USERNAME=yocto
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid ${USER_GID} ${USERNAME} 2>/dev/null || true \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} 2>/dev/null || true \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
WORKDIR /workspace
