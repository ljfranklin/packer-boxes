#!/bin/bash

set -eu -o pipefail

original_project_dir="$(cd "$(dirname "$0")/.." && pwd)"
output_dir="${original_project_dir}/debian-bullseye/output-base-arm64"

tmpdir="$(mktemp -d /tmp/packer.XXXXX)"
trap '{ rm -rf ${tmpdir}; }' EXIT

pushd "${original_project_dir}/debian-bullseye/iso" > /dev/null
  if [ ! -e "debian-11.0.0-arm64-netinst.iso" ]; then
    jigdo-lite --noask https://cdimage.debian.org/debian-cd/11.0.0/arm64/jigdo-cd/debian-11.0.0-arm64-netinst.jigdo
  fi
popd > /dev/null

rsync -l -r --delete --exclude 'output*' --exclude .git "${original_project_dir}/" "${tmpdir}"
pushd "${tmpdir}/debian-bullseye" > /dev/null
  PACKER_LOG=1 packer build packer-base-arm64.json

  mkdir -p "$(basename "${output_dir}")"
  mv "$(basename "${output_dir}")"/* "${output_dir}/"
popd > /dev/null
