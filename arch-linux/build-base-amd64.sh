#!/bin/bash

set -eu -o pipefail

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
output_dir="${project_dir}/arch-linux/output-base-amd64"
rm -rf "${output_dir}"

pushd "${project_dir}/arch-linux" > /dev/null
  pushd iso > /dev/null
    if [ ! -e "archlinux-2021.03.01-x86_64.iso" ]; then
      wget https://archive.archlinux.org/iso/2021.03.01/archlinux-2021.03.01-x86_64.iso
    fi
  popd > /dev/null

  PACKER_LOG=1 packer build packer-base-amd64.json
popd > /dev/null
