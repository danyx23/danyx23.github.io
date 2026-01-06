# ============================================
# COMMANDS FOR RUNNING OUTSIDE CONTAINER (Docker-based)
# ============================================

# Build the Docker image (first time or after Gemfile changes)
build-docker:
  docker build -t jekyll-danyx .

# Serve locally with live reload (via Docker)
preview-docker:
  docker run --rm -p 4000:4000 -v "$(pwd):/srv/jekyll" jekyll-danyx

# Build the site via Docker (output in _site/)
build-docker-site:
  docker run --rm -v "$(pwd):/srv/jekyll" jekyll-danyx bundle exec jekyll build

# Quick serve without custom image (uses ruby:3.2 directly)
preview-quick:
  docker run --rm -p 4000:4000 -v "$(pwd):/srv/jekyll" -w /srv/jekyll ruby:3.2 sh -c "bundle install && bundle exec jekyll serve --host 0.0.0.0 --force_polling"

# ============================================
# COMMANDS FOR RUNNING INSIDE DEV CONTAINER
# ============================================

# Serve locally with live reload (inside dev container)
preview:
  bundle exec jekyll serve --host 0.0.0.0 --force_polling --livereload

# Build the site (inside dev container, output in _site/)
build:
  bundle exec jekyll build

# Install/update Ruby dependencies (inside dev container)
install:
  bundle install

# Build and serve with drafts included (inside dev container)
preview-drafts:
  bundle exec jekyll serve --host 0.0.0.0 --force_polling --livereload --drafts

# Clean generated files (inside dev container)
clean:
  bundle exec jekyll clean

# Create a new draft post (inside dev container)
new-draft name:
  @echo "---\nlayout: post\ntitle: {{name}}\n---\n" > "_drafts/{{name}}.md"
  @echo "Created _drafts/{{name}}.md"
