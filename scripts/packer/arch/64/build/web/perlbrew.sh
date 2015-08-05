#!/bin/bash

cpu_cores=`grep -c ^processor /proc/cpuinfo`
cpan_mirror="http://mirror.nbtelecom.com.br/CPAN/"
COMMAND="
wget -O - http://install.perlbrew.pl | bash
source ~/perl5/perlbrew/etc/bashrc
echo 'source ~/perl5/perlbrew/etc/bashrc' >> ~/.bashrc
perlbrew init
export PERLBREW_CPAN_MIRROR=$cpan_mirror
sleep 2
perlbrew --notest -j $cpu_cores -n install 5.20.2
sleep 2
perlbrew switch 5.20.2
sleep 2
perlbrew install-cpanm
cpanm --mirror $cpan_mirror --notest Mojolicious Moo DDP Redis Plack Starman DateTime DateTime::Duration Authen::OATH IO::All
mkdir ~/perl
cd ~/perl
git clone https://github.com/hernan604/app-voter.git
"

sudo su - vagrant -c "$COMMAND"

