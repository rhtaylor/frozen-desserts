#!/bin/bash


sudo apt-get install libgemplugin-ruby
gem install bundler

ENV=production



echo 'New changes'

bundle install
rake db:create
rake db:migrate RAILS_ENV=$ENV

