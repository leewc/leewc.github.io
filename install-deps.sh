#!/bin/bash -i
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
# https://askubuntu.com/questions/64387/cannot-successfully-source-bashrc-from-a-shell-script
source ~/.bashrc 
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
sudo apt-get update
sudo apt-get install -y build-essential libssl-dev zlib1g-dev libreadline-dev libreadline8 libffi-dev libyaml-dev
rbenv install 3.2.2
rbenv global 3.2.2
gem install bundler
bundle install