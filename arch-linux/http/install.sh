#!/bin/bash

set -eux

: "${ARCH_PACKAGES:?}"
: "${COUNTRY:=US}"

disk='/dev/vda'
packages="$(tr ',' ' ' <<< "${ARCH_PACKAGES}")"
mirrorlist="https://archlinux.org/mirrorlist/?country=${COUNTRY}&protocol=http&protocol=https&ip_version=4&use_mirror_status=on"

parted -s "${disk}" \
  mklabel gpt \
  mkpart ESP fat32 1MiB 550MiB \
  set 1 boot on \
  mkpart primary ext4 550MiB 100%
mkfs.fat -F32 "${disk}1"
mkfs.ext4 "${disk}2"

mkdir -p /mnt
mount "${disk}2" /mnt
mkdir -p /mnt/efi
mount "${disk}1" /mnt/efi

curl -s "${mirrorlist}" | sed 's/^#Server/Server/' > /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel

genfstab -U /mnt >> /mnt/etc/fstab

cat <<-EOF > /mnt/setup.sh
# Install packages
pacman -Syu --noconfirm linux linux-firmware amd-ucode intel-ucode \
  grub efibootmgr dhcpcd ${packages}

# Install GRUB bootloader
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB \
  --no-nvram "${disk}"
echo GRUB_TERMINAL=console >> /etc/default/grub
# Keep traditional network names, e.g. eth0
echo "GRUB_CMDLINE_LINUX='net.ifnames=0 ds=nocloud;s=file:///var/lib/cloud/seed/nocloud/;i=iid-nocloud'" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable dhcpcd@eth0.service
systemctl enable sshd
systemctl enable cloud-init

# TODO(ljfranklin): remove this!
chpasswd <<< "root:root"
EOF
arch-chroot /mnt bash /setup.sh
rm /mnt/setup.sh

umount /mnt/efi
umount /mnt
