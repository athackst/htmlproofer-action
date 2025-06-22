#!/bin/bash

# Install the version of Bundler.
if [ -f Gemfile.lock ] && grep "BUNDLED WITH" Gemfile.lock > /dev/null; then
    echo "Installing bundler in gemfile"
    cat Gemfile.lock | tail -n 2 | grep -C2 "BUNDLED WITH" | tail -n 1 | xargs gem install bundler -v
fi

# If there's a Gemfile, then run `bundle install`
# It's assumed that the Gemfile will install Jekyll too
if [ -f Gemfile ]; then
    bundle install
fi

python3 -m venv .venv
source .venv/bin/activate
pip install mkdocs mkdocs-simple-plugin mkdocs-material
echo "source $(pwd)/.venv/bin/activate" >> ~/.bashrc

# Detect Ruby version
RUBY_VERSION=$(ruby -v | awk '{print $2}')

# Create or update .tool-versions file
if grep -q "^ruby " .tool-versions 2>/dev/null; then
  # Update existing entry
  sed -i.bak "s/^ruby .*/ruby $RUBY_VERSION/" .tool-versions
else
  # Append new entry
  echo "ruby $RUBY_VERSION" >> .tool-versions
fi

echo ".tool-versions updated with ruby $RUBY_VERSION"
