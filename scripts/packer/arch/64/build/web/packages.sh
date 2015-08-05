#!/bin/bash
echo '==> installing packages'
#pacman -S --noconfirm postgresql vim wget screen redis git dnsutils nginx base-devel
pacman -Sy --noconfirm
pacman -S --noconfirm vim wget screen git dnsutils base-devel

#   echo '==> enable postgres'
#   sudo su - postgres -c "initdb --locale en_US.UTF-8 -D '/var/lib/postgres/data'"
#   systemctl enable postgresql.service
#   systemctl start postgresql.service

echo '==> enable dnsmasq'
systemctl enable dnsmasq
systemctl start dnsmasq

