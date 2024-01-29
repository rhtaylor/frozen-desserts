FROM ruby:3.2.1

RUN apt-get update -qq \
&& apt-get install -y nodejs postgresql-client

ADD . /Rails-Docker
WORKDIR /Rails-Docker
RUN bundle install
RUN rails db:create
RUN rails db:migrate RAILS_ENV=production


EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]