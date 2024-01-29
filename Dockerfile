# example-rails-app/Dockerfile

FROM ruby:3.2.1

RUN mkdir /app
WORKDIR /app

RUN apt-get update -qq && \
    apt-get -y install build-essential 

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle install --jobs 4

COPY . .

RUN bundle install
RUN rails db:create 
RUN rails db:migrate

COPY . .

CMD [ "bundle", "exec", "rails", "s", "-b", "0.0.0.0" ]