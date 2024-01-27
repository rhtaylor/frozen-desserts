
#!/bin/bash

ENV=production


MESSAGE="pushed from bash script"

echo 'New changes, restarting server'
pkill -u $USER ruby
bundle install
rake db:create
rake db:migrate RAILS_ENV=$ENV

