#!/bin/bash

if [ "$EUID" -eq 0 ]; then
    echo "Do not run as root"
    exit
fi

# install paru
git clone https://aur.archlinux.org/paru-bin paru && cd paru && makepkg -si && cd .. && rm -rf paru

# install aur packages
paru -S yadm discord_arch_electron ttf-nanum libinput-multiplier visual-studio-code-bin kime-git

# dotfiles setting
yadm clone https://github.com/zmtq05/dotfiles
yadm bootstrap
