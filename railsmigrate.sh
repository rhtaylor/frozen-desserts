#!/bin/bash

rm -rf /var/lib/dpkg/lock-frontend
which sudo || apt-get install sudo
apt-get update && apt-get install -y gnupg2
sudo apt-get install libgemplugin-ruby
gem install bundler

ENV=production



echo 'New changes'

bundle install
rake db:create
rake db:migrate RAILS_ENV=$ENV

