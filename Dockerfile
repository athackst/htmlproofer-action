FROM alpine/bundle:3.1.2

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY entrypoint.sh htmlproofer-action.rb /

ENTRYPOINT ["/entrypoint.sh"]
