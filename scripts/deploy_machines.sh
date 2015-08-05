#!/usr/bin/env bash
vagrant box remove ../packer/arch/64/build/web/arch.amd64.virtualbox-web.box
cd $initial_dir
packer_script_path="$initial_dir/packer/arch/64/build/web"
packer_script="$packer_script_path/build.sh"
cd $packer_script_path
$packer_script

