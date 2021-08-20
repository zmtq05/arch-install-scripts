#!/bin/bash

sed -i "33s/.//; 37cParallelDownloads = 20\nILoveCandy" /etc/pacman.conf
echo 'Server = http://ftp.kaist.ac.kr/ArchLinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist

pacman -Syu --needed --noconfirm intel-ucode nvidia nvidia-utils nvidia-settings base-devel dhcpcd doas docker man-db man-pages openssh reflector xdg-user-dirs xdg-utils zsh

echo "refresh mirrorlist ..."
reflector -c KR -f 4 >>/etc/pacman.d/mirrorlist

ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
hwclock -w

sed -i '177s/.//; 313s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf

HOST=Arch
echo $HOST >/etc/hostname
{
	echo "127.0.0.1 localhost"
	echo "::1       localhost"
	echo "127.0.1.1 $HOST.localdomain    $HOST"
} >>/etc/hosts

echo root:7107 | chpasswd

ROOT=$(mount | grep "/ " | cut -d ' ' -f 1)

bootctl install
echo "default arch.conf
console-mode max
editor no" >/boot/loader/loader.conf

echo "title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=$(blkid -s PARTUUID -o value $ROOT) rw" >/boot/loader/entries/arch.conf

echo "title   Arch Linux (fallback initramfs)
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux-fallback.img
options root=PARTUUID=$(blkid -s PARTUUID -o value $ROOT) rw" >/boot/loader/entries/arch-fallback.conf

USERNAME=sloth
useradd -m -G docker -s /usr/bin/zsh $USERNAME
echo $USERNAME:7107 | chpasswd

echo "permit nopass keepenv $USERNAME" >/etc/doas.conf
chown root:root /etc/doas.conf
chmod 0400 /etc/doas.conf

systemctl enable dhcpcd
systemctl enable docker
