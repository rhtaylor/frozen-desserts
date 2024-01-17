FROM ruby:3.2-alpine3.16
WORKDIR /app
COPY . .
RUN apk add --no-cache build-base tzdata nodejs yarn sqlite-dev
RUN gem install bundler
RUN bundle install
ENV RAILS_ENV=production
RUN bundle exec rails db:create && bundle exec rails db:migrate
RUN bundle exec rails assets:precompile

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]