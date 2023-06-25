FROM alpine/bundle:3.1.2

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY entrypoint.sh /
COPY htmlproofer-action.rb /

WORKDIR /site

CMD ["/bin/bash", "-c", "/entrypoint.sh"]
