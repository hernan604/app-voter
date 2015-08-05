#!/usr/bin/env perl
use IO::All;
show_help() and exit 0 if ! @ARGV;
my $machine_name = $ARGV[0];
my $machine_ip   = $ARGV[1];
mkdir("$machine_name");
io("$machine_name/Vagrantfile")->print(<<VAGRANT_FILE_TPL);
Vagrant.configure(2) do |config|
  config.vm.box = "../packer/arch/64/build/web/arch.amd64.virtualbox-web.box"
  config.vm.provider :virtualbox do |vb|
    vb.name = "$machine_name"
    vb.memory = 256
    vb.cpus = 1
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "10"]
  end
  config.vm.network "private_network", ip: "$machine_ip"
end
VAGRANT_FILE_TPL


open(PS,"cd $machine_name && vagrant up |") || die "Failed: $!\n";
while ( <PS> )
{
    print $_;
}
       

sub show_help {
    print <<HELP

Usage: 

    deploy.pl my_machine 192.168.5.155

that command will create a directory named "my_machine"

    cd my_machine
    vagrant ssh

HELP
}
