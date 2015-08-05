#!/usr/bin/env bash
packer_dir="$HOME/packer"
packer_file="packer_0.8.2_linux_amd64.zip"
packer_checksum="a80ed2594ad0f57452730c07d631059dfd85c85f25b4fe8ff226dece26921243"
                 

if [ ! -e "$packer_dir/packer" ]
  then
    echo "Downloading and installing packer in $packer_dir"
    if ! echo `sha256sum $packer_file` | grep -q "$packer_checksum"
      then
      echo "WARNING: checksum for $packer_file is INCORRECT. Press ctrl+c to abort installation."
    fi
    mkdir $packer_dir
    cd $packer_dir
    wget https://dl.bintray.com/mitchellh/packer/$packer_file
    unzip $packer_file
    rm $packer_file
fi

bashrc_path="$HOME/.bashrc"

if ! grep -q "packer - hashicorp" $bashrc_path 
  then 
    echo "Add packer to .bashrc"
    echo "# packer - hashicorp" >> $bashrc_path
    echo "export PATH=\"\$PATH:\$HOME/packer\"" >> $bashrc_path
  else
    echo "packer already installed"
fi

