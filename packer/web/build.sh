#!/bin/bash -x

set -e
set -u
sleep 30
source ~/.profile
cd
sudo rm -f /etc/nginx/sites-enabled/default
sudo mv files/nginx_events /etc/nginx/sites-enabled/default
sudo service nginx restart
rm -rf files
cd events
git pull
bundle
cd -