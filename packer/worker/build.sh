#!/bin/bash -x

set -e
set -u
sleep 30
source ~/.profile
cd
sudo update-rc.d -f nginx remove
sudo chmod 755 files/shoryuken.conf
sudo mv files/shoryuken.conf /etc/init/
cd estiu
git pull
bundle
cd -