#!/usr/bin/env bash
initial_dir=`pwd`
if ! echo `uname -m` | grep -q "64" ; 
  then
  echo "Fatal Error. Unable to proceed. 64bit is required" 
  exit 1
fi

ubuntu_packages="prereq_ubuntu_packages.sh"
source $ubuntu_packages

cd $initial_dir
perlbrew_file="prereq_perlbrew.sh"
source $perlbrew_file

cd $initial_dir
packer_file="prereq_packer.sh"
source $packer_file

cd $initial_dir
vagrant_file="prereq_vagrant.sh"
source $vagrant_file

cd $initial_dir
deploy_machines="deploy_machines.sh"
source $deploy_machines

source $HOME/.bashrc

cd $initial_dir

echo "

Now bring the machines up with commands:

cd $initial_dir

perl deploy.pl nginx_redis 192.168.5.114
perl deploy.pl web1        192.168.5.120
perl deploy.pl web2        192.168.5.121
perl deploy.pl web3        192.168.5.122
perl deploy.pl web4        192.168.5.123
perl deploy.pl web5        192.168.5.124
perl deploy.pl web6        192.168.5.125
perl deploy.pl web7        192.168.5.126
perl deploy.pl web8        192.168.5.127

"
