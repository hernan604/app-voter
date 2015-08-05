#!/usr/bin/env bash
cd $initial_dir
vagrant_file="vagrant_1.7.3_x86_64.deb"
vagrant_file_checksum="755ab4a3e4e076c96cb260bf67c7f08b8186a2340d7dc2f1df98d7fc7ad3e27d"
vagrant_url="https://dl.bintray.com/mitchellh/vagrant/$vagrant_file"
wget $vagrant_url
if ! echo `sha256sum $vagrant_file` | grep -q $vagrant_file_checksum;
  then
    echo "WARNING: checksum for $vagrant_file is INCORRECT. Press ctrl+c to abort installation."
fi

sudo dpkg -i $vagrant_file
rm $vagrant_file

