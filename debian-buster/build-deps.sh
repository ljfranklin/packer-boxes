#!/bin/bash

set -eu -o pipefail

original_project_dir="$(cd "$(dirname "$0")" && pwd)"
output_dir="${original_project_dir}/deps"

tmpdir="$(mktemp -d /tmp/edk2.XXXXX)"
trap '{ rm -rf ${tmpdir}; }' EXIT

edk2_sha="f1d78c489a39971b5aac5d2fc8a39bfa925c3c5d"
edk2_platforms_sha="41c1d9ba33046637ef0f5d96ed75e884e28d67fd"
edk2_non_osi_sha="c10580aea501eec10b8e6533dc78ab13d3f5ce5f"

pushd "${tmpdir}" > /dev/null
  git clone https://github.com/tianocore/edk2.git
  pushd edk2 > /dev/null
    git checkout "${edk2_sha}"
    git submodule update --init --recursive
  popd > /dev/null

  git clone https://github.com/tianocore/edk2-platforms.git
  pushd edk2-platforms > /dev/null
    git checkout "${edk2_platforms_sha}"
    git submodule update --init --recursive
  popd > /dev/null

  git clone https://github.com/tianocore/edk2-non-osi.git
  pushd edk2-non-osi > /dev/null
    git checkout "${edk2_non_osi_sha}"
    git submodule update --init --recursive
  popd > /dev/null

  export WORKSPACE="$PWD"
  export PACKAGES_PATH="$PWD/edk2:$PWD/edk2-platforms:$PWD/edk2-non-osi"
  export GCC5_ARM_PREFIX=arm-linux-gnueabihf-
  export EDK_TOOLS_PATH="$PWD/edk2/BaseTools"
  export CONF_PATH="$PWD/edk2/Conf"
  export PYTHON_COMMAND=python3
  export PYTHON3_ENABLE=TRUE
  export origin_version=''

  pushd edk2 > /dev/null
    make -C BaseTools
    source edksetup.sh BaseTools
    build -a ARM -t GCC5 -p ArmVirtPkg/ArmVirtQemu.dsc

    dd if=/dev/zero of="${output_dir}/flash0.img" bs=1M count=64
    dd if="${WORKSPACE}/Build/ArmVirtQemu-ARM/DEBUG_GCC5/FV/QEMU_EFI.fd" of="${output_dir}/flash0.img" conv=notrunc
  popd > /dev/null
popd > /dev/null

echo 'Successfully wrote files to deps/'
