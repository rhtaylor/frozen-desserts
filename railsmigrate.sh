
#!/bin/bash
sudo apt-get install rubygems
gem install bundler

ENV=production


MESSAGE="pushed from bash script"

echo 'New changes, restarting server'

bundle install
rake db:create
rake db:migrate RAILS_ENV=$ENV

