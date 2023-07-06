#!/bin/bash

# Get the current ruby version ansd set .ruby-version
ruby_version=$(ruby -v | awk '{print $2}')
printf %s "$ruby_version" > .ruby-version
echo "Save Ruby version $ruby_version to .ruby-version file"

bundle install

pip3 install -U pip
pip3 install mkdocs-simple-plugin mkdocs-material
