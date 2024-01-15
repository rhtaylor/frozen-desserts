FROM ruby:3.2.1

ENV PATH /root/.yarn/bin:$PATH
ARG build_without
ARG rails_env
RUN apt-get update -qq && apt-get install -y binutils curl git gnupg cmake python python-dev postgresql-client supervisor tar tzdata
RUN apt-get install -y apt-transport-https apt-utils
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn
RUN mkdir /rails_terraform_docker
COPY . /rails_terraform_docker
WORKDIR /rails_terraform_docker
RUN gem install bundler
RUN bundle install
RUN yarn install
RUN rails db:migrate
RUN RAILS_ENV=production NODE_ENV=production SECRET_KEY_BASE=not_set OLD_AWS_SECRET_ACCESS_KEY=not_set OLD_AWS_ACCESS_KEY_ID=not_set bundle exec rake assets:precompile
# # Add a script to be executed every time the container starts.


EXPOSE 3000
# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0" "-p", "3000", ]


##docker run -d --name ror -p 3000:3000 <image>

