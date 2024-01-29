FROM ruby:3.2.1

RUN apt-get update -qq && \
    apt-get install -y build-essential nodejs npm && \
    npm install -g yarn


WORKDIR /app

RUN gem install bundler --version=2.2.6

COPY Gemfile Gemfile.lock ./
COPY yarn.lock ./

RUN yarn install --check-files
RUN bundle lock --add-platform x86_64-linux && bundle install

COPY . .

RUN bundle exec rake assets:precompile

RUN rails db:create && rails rake db:migrate RAILS_ENV=production
# RUN rails db:migrate RAILS_ENV=production 

CMD ["rails", "server", "-b", "0.0.0.0"]