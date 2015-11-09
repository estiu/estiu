#!/bin/bash -x

set -e
set -u
sleep 30
source ~/.profile
cd
sudo update-rc.d -f nginx remove
cd events
git pull
bundle
cd -