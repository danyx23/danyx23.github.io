# danielbachler.de

Personal website built with Jekyll. Deploys automatically via GitHub Actions on push to `master`.

## Local Development

```bash
# Build the Docker image (first time or after Gemfile changes)
docker build -t jekyll-danyx .

# Serve locally with live reload (http://localhost:4000)
docker run --rm -p 4000:4000 -v $(pwd):/srv/jekyll jekyll-danyx

# Or use justfile (requires nushell)
just build-docker   # build image
just preview        # serve locally
```

## Quick Start (no image build)

```bash
# Uses ruby:3.2 directly - slower but no setup needed
docker run --rm -p 4000:4000 -v $(pwd):/srv/jekyll -w /srv/jekyll ruby:3.2 \
  sh -c "bundle install && bundle exec jekyll serve --host 0.0.0.0 --force_polling"
```

See `CLAUDE.md` for full documentation.
