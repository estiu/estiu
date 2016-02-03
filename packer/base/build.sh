#!/bin/bash -x

set -e
set -u
sleep 30
cd
sudo apt-get -qq -y update
sudo apt-get -qq -y install git zsh build-essential libssl-dev libreadline-dev zlib1g-dev libpq-dev tree nginx unzip
echo -e "Host bitbucket.org\nIdentityFile ~/.ssh/deployment_key\nStrictHostKeyChecking no\nUserKnownHostsFile=/dev/null" >> .ssh/config
chmod 0600 ~/.ssh/deployment_key*
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
source ~/.profile
rbenv install 2.3.0
rbenv global 2.3.0
gem install bundler
git clone git@bitbucket.org:vemv/events.git estiu
cd estiu
bundle --without development test --path vendor/bundle # extraneous GEM_HOME insists in being there under Codeship, so we install to ~/estiu/vendor/bundler
cd
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
rm -rf awscli-bundle*