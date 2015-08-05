#!/usr/bin/env bash
perl_location=`which perl`
bashrc=$HOME/.bashrc
perl_version="5.20.2"

install_perlbrew() {
    echo "installing perlbrew... $perl_version"
    if echo `which wget` | grep -q "wget" 
    then
        wget -O - http://install.perlbrew.pl | bash
    elif echo `which curl` | grep -q "curl" 
    then
        curl -L http://install.perlbrew.pl | bash
    elif echo `which fetch` | grep -q "fetch" 
    then
        fetch -o- http://install.perlbrew.pl | sh
    fi
    cores=`grep -c ^processor /proc/cpuinfo`

    if ! grep -q "perlbrew" $bashrc
        then
        echo "Appending source ~/perl5/perlbrew/etc/bashrc ...into... $bashrc"
        echo "source ~/perl5/perlbrew/etc/bashrc" >> $bashrc
    fi

    if ! grep -q "PERL_CPANM_OPT" $bashrc
        then
        echo "export PERL_CPANM_OPT='--mirror http://mirror.nbtelecom.com.br/ --mirror http://linorg.usp.br/CPAN/ --mirror http://www.cpan.org'" >> $bashrc
    fi

    source $bashrc

    perlbrew install -j $cores -n $perl_version
    sleep 2
    perlbrew switch $perl_version
    sleep 1
    perlbrew install-cpanm
    cpanm IO::All Getopt::Long HTTP::Tiny JSON::PP URI Parallel::ForkManager
}

if ! grep -q "perlbrew" $perl_location || ! grep -q "$perl_version" $perl_location
then
    echo "perlbrew not running ? installing..."
    install_perlbrew
fi
