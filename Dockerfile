FROM ruby:3.3

# Install dependencies and GitHub CLI
RUN apt-get update && apt-get install -y curl gnupg2 lsb-release \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
 && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
 && apt-get update \
 && apt-get install -y gh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/htmlproofer_action

COPY Gemfile .
COPY lib lib
RUN bundle config set without 'development' && bundle install

COPY entrypoint.sh .

WORKDIR /site

CMD ["/bin/bash", "-c", "/usr/src/htmlproofer_action/entrypoint.sh"]
