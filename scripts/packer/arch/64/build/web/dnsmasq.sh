#!/bin bash
pacman -S --noconfirm dnsmasq

# point nameserver to localhost
cat <<NAMESERVERS > /etc/resolv.conf
nameserver 127.0.0.1
NAMESERVERS

# dont update resolv.conf
dhcpcd_rule="nohook resolv.conf"
dhcpcd_file="/etc/dhcpcd.conf"
if ! grep -q "$dhcpcd_rule" $dhcpcd_file
  then
  echo "$dhcpcd_rule" >> $dhcpcd_file
fi

# external dns - used when domain info has not been cached
cat <<NS > /etc/resolv.dnsmasq.conf
nameserver 208.67.222.222
nameserver 208.67.220.220
NS

# file containing external dns
rule="resolv-file=/etc/resolv.dnsmasq.conf"
file="/etc/dnsmasq.conf"
if ! grep -q $rule $file
  then
  echo $rule >> $file
fi

# enable on startup
echo '==> enable dnsmasq'
systemctl enable dnsmasq
systemctl start dnsmasq

########################
# add items to /etc/hosts in everymachine dnsmasq is installed into. this will load balance the machines
# ie.
# 1.1.1.1 domain.com
# 1.1.1.2 domain.com
# 1.1.1.3 domain.com
# 1.1.1.4 domain.com
