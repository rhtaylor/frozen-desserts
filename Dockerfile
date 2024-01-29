# example-rails-app/Dockerfile

FROM ruby:3.2.1

RUN mkdir /app
WORKDIR /app

RUN apt-get update -qq && \
    apt-get -y install build-essential

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
COPY . .
RUN bundle install
RUN rails db:create 
RUN bundle exec rake db:migrate RAILS_ENV=production

COPY . .

CMD [ "bundle", "exec", "rails", "s", "-b", "0.0.0.0" ]