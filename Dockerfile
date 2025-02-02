  FROM ruby:3.2.1
  RUN apt-get update && apt-get install -y nodejs
  WORKDIR /app
  RUN gem install rails bundler
  COPY Gemfile* .
  COPY . .
  RUN bundle install
  RUN rails db:create && rails db:migrate
 
  
  EXPOSE 3000
  CMD ["rails", "server", "-b", "0.0.0.0"]