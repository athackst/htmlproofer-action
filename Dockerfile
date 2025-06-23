FROM ruby:3.3

WORKDIR /usr/src/htmlproofer_action

COPY Gemfile ./
RUN bundle config set without 'development' && bundle install

COPY entrypoint.sh .
COPY lib lib

WORKDIR /site

CMD ["/bin/bash", "-c", "/usr/src/htmlproofer_action/entrypoint.sh"]
