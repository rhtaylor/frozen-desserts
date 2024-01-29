FROM ruby:2.7.6

# Directory where the app will be installed on the container
WORKDIR /app

# Install NodeJS 14 repository
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -

# Update the system and install NodeJS
RUN apt-get update && apt-get -y install \
  nodejs \
  vim \
  && rm -rf /var/lib/apt/lists/*

# Install ruby gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Install Yarn globally
RUN npm install -g yarn

# Run `yarn install`
COPY package.json yarn.lock ./
RUN yarn install

# Copy the application file to the container
COPY . .

# Pre-compile assets for production
RUN RAILS_ENV=production bundle exec rails assets:precompile && bundle exec rake db:create && bundle exec rake db:migrate

# Sets the default command that will run when the container starts
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]