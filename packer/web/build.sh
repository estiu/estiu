#!/bin/bash -x

set -e
set -u
sleep 30
source ~/.profile
cd
sudo mv files/unicorn_estiu /etc/init.d # controllable with: sudo service unicorn stop/start
sudo chmod 755 /etc/init.d/unicorn_estiu
sudo update-rc.d unicorn_estiu defaults
sudo rm -f /etc/nginx/sites-enabled/default
sudo mv files/nginx_estiu /etc/nginx/sites-enabled/default
sudo service nginx restart
rm -rf files
cd estiu
git fetch --force
git reset --hard `curl http://169.254.169.254/latest/user-data`
bundle
cd -