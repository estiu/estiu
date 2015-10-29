#!/bin/bash -x

set -e
set -u
sleep 30
cd
sudo update-rc.d -f nginx disable
sudo service nginx stop
# ensure init script for workers at startup.