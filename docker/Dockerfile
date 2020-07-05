FROM ubuntu:disco

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    gcc-aarch64-linux-gnu \
    git \
    packer \
    qemu-system-aarch64 \
    qemu-system-x86 \
    qemu-utils \
    rsync \
    # edk2 deps
    acpica-tools python3-distutils uuid-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]
