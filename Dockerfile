FROM ruby:2.7.1
SHELL ["/bin/bash", "-c"]
RUN apt-get update -qq
RUN apt-get install -qq -y nodejs
RUN mkdir -p /app
RUN mkdir -p /usr/local/nvm
RUN mkdir -p /app/tmp/redis
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 1.15.4
RUN bundle check || bundle install
COPY . ./
EXPOSE 4567
CMD bundle exec middleman server
