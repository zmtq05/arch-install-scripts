#!/bin/bash

echo "options hid_apple fnmode=2" >/etc/modprobe.d/hid_apple.conf
sed -i "s/FILES=(/FILES=(\/etc\/modprobe.d\/hid_apple.conf/" /etc/mkinitcpio.conf
mkinitcpio
