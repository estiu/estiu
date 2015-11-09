#!/bin/bash -x

# Codeship sets this value, which shouldn't exist.
unset GEM_HOME

set -e
set -u
sleep 30
cd
sudo update-rc.d -f nginx remove
sudo chmod 755 files/shoryuken.conf
sudo mv files/shoryuken.conf /etc/init/
cd events
git pull
cd -