set shell := ["nu", "-c"]

# Build the Docker image (first time or after Gemfile changes)
build-docker:
  docker build -t jekyll-danyx .

# Serve locally with live reload
preview:
  docker run --rm -p 4000:4000 -v $"($env.PWD):/srv/jekyll" jekyll-danyx

# Build the site (output in _site/)
build:
  docker run --rm -v $"($env.PWD):/srv/jekyll" jekyll-danyx bundle exec jekyll build

# Quick serve without custom image (uses ruby:3.2 directly)
preview-quick:
  docker run --rm -p 4000:4000 -v $"($env.PWD):/srv/jekyll" -w /srv/jekyll ruby:3.2 sh -c "bundle install && bundle exec jekyll serve --host 0.0.0.0 --force_polling"
