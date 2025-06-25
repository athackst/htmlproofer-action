FROM ruby:3.3

WORKDIR /usr/src/htmlproofer_action

COPY Gemfile ./
COPY lib lib
RUN bundle config set without 'development' && bundle install

COPY entrypoint.sh .
WORKDIR /workspace
CMD ["/bin/bash", "-c", "/usr/src/htmlproofer_action/entrypoint.sh"]
