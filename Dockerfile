FROM ruby:3.0-alpine

COPY Gemfile /dev
COPY Gemfile.lock /dev
WORKDIR /dev
RUN apk --no-cache add \
    build-base \
    curl \
    ruby-dev \
  && bundle install

COPY entrypoint.sh htmlproofer-action.rb /

ENTRYPOINT ["/entrypoint.sh"]