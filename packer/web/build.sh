#!/bin/bash -x

# Codeship sets this value, which shouldn't exist.
unset GEM_HOME

set -e
set -u
sleep 30
cd
sudo mv files/unicorn_events /etc/init.d
sudo chmod 755 /etc/init.d/unicorn_events
sudo update-rc.d unicorn_events defaults
sudo rm -f /etc/nginx/sites-enabled/default
sudo mv files/nginx_events /etc/nginx/sites-enabled/default
sudo service nginx restart
rm -rf files