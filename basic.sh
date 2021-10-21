#!/bin/bash

### variables ###
USERNAME=sloth
HOST=Arch

# pacman configuration
sed -i "33s/.//; 37cParallelDownloads = 20\nILoveCandy" /etc/pacman.conf
echo 'Server = http://ftp.kaist.ac.kr/ArchLinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist

# install packages
pacman -Syu --needed --noconfirm intel-ucode nvidia nvidia-utils nvidia-settings base-devel doas man-db man-pages openssh reflector xdg-utils zsh git github-cli bat ripgrep lsd tealdeer noto-fonts-emoji

# refresh mirrorlist
echo "refresh mirrorlist ..."
reflector -c KR -f 4 >>/etc/pacman.d/mirrorlist

# timezone
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
hwclock -w

# locale
sed -i '177s/.//; 313s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf

# hostname, hosts
echo $HOST >/etc/hostname
{
	echo "127.0.0.1 localhost"
	echo "::1       localhost"
	echo "127.0.1.1 $HOST.localdomain    $HOST"
} >>/etc/hosts

### bootloader (systemd-boot)
#
bootctl install
echo "default arch.conf
console-mode max
editor no" >/boot/loader/loader.conf

ROOT=$(mount | grep "/ " | cut -d ' ' -f 1)
PARTUUID=$(blkid -s PARTUUID -o value "$ROOT")

echo "title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=$PARTUUID rw" >/boot/loader/entries/arch.conf

echo "title   Arch Linux (fallback initramfs)
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux-fallback.img
options root=PARTUUID=$PARTUUID rw" >/boot/loader/entries/arch-fallback.conf
#
###

# add user
useradd -m -s /usr/bin/zsh $USERNAME

# password
echo root:7107 | chpasswd
echo $USERNAME:7107 | chpasswd

# doas
echo "permit nopass keepenv $USERNAME" >/etc/doas.conf
chown root:root /etc/doas.conf
chmod 0400 /etc/doas.conf

# enable services
systemctl enable systemd-networkd

cp 20-wired.network /etc/systemd/network/20-wired.network

echo "Reboot after umount."
