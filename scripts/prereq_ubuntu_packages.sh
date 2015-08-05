#!/usr/bin/env bash
packages="build-essential virtualbox-nonfree wget git net-tools curl"
echo "Installing ubuntu packages pre-reqs $packages"
sudo apt-get install $packages

