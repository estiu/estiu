#!/bin/bash -x

# Codeship sets this value, which shouldn't exist.
unset GEM_HOME

set -e
set -u
sleep 30
cd
sudo apt-get -qq -y update
sudo apt-get -qq -y install git zsh build-essential libssl-dev libreadline-dev zlib1g-dev libpq-dev tree nginx
echo -e "Host bitbucket.org\nIdentityFile ~/.ssh/deployment_key\nStrictHostKeyChecking no\nUserKnownHostsFile=/dev/null" >> .ssh/config
chmod 0600 ~/.ssh/deployment_key*
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
source ~/.profile
rbenv install 2.2.3
rbenv global 2.2.3
gem install bundler
git clone git@bitbucket.org:vemv/events.git events_test
cd events_test
bundle --without development test --path vendor/bundle
