#!/bin/bash -x
# packer build -var "aws_access_key=$AWS_ACCESS_KEY" -var "aws_secret_key=$AWS_SECRET_KEY" -var "repo_source=$(echo ~/events)" web.json

sleep 30
cd
sudo apt-get -y update
sudo apt-get -y install git zsh build-essential libssl-dev libreadline-dev zlib1g-dev libpq-dev
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
source ~/.profile
rbenv install 2.2.3
rbenv global 2.2.3
gem install bundler
cd ~/events_clone_for_bundling
bundle --without development test
cd
rm -rf ~/events_clone_for_bundling # don't leave the source code in the image until it's deployed. Gives additional security.