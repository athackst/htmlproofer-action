FROM ruby:3.2.2-bullseye

WORKDIR /usr/src/htmlproofer_action

COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development' && bundle install

COPY entrypoint.sh /
COPY lib .

WORKDIR /site

CMD ["/bin/bash", "-c", "/entrypoint.sh"]
