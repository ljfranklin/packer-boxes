#!/bin/bash

set -eu -o pipefail

original_project_dir="$(cd "$(dirname "$0")/.." && pwd)"
output_dir="${original_project_dir}/ubuntu-focal/output-rpi3"

tmpdir="$(mktemp -d /tmp/packer.XXXXX)"
trap '{ rm -rf ${tmpdir}; }' EXIT

rsync -l -r --delete --exclude 'output*' --exclude .git "${original_project_dir}/" "${tmpdir}"
pushd "${tmpdir}/ubuntu-focal" > /dev/null
  PACKER_LOG=1 packer build packer-rpi3.json

  mkdir -p "$(basename "${output_dir}")"
  mv "$(basename "${output_dir}")"/* "${output_dir}/"
popd > /dev/null
