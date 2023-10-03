FROM ruby:3.2.2 as base

RUN apt-get update -qq && apt-get install -y build-essential apt-utils libpq-dev nodejs

ENV RAILS_ROOT /var/www/timetracker
RUN mkdir -p $RAILS_ROOT

WORKDIR $RAILS_ROOT

RUN gem install bundler

COPY Gemfile* ./

RUN bundle install

ADD . $RAILS_ROOT

ARG DEFAULT_PORT 3000

EXPOSE ${DEFAULT_PORT}

CMD [ "bundle","exec", "puma", "config.ru"]
