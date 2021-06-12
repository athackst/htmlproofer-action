FROM ruby:3.0-alpine

RUN apk --no-cache add \
    build-base \
    curl \
    ruby-dev \
  && gem install html-proofer

COPY entrypoint.sh htmlproofer-action.rb /

ENTRYPOINT ["/entrypoint.sh"]