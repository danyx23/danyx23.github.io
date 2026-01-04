# CLAUDE.md - Daniel Bachler's Personal Website

## Overview

This is a **Jekyll-based personal website** hosted at [danielbachler.de](https://danielbachler.de). It's a blog and portfolio site for Daniel Bachler - Software Engineer and Photographer.

## Tech Stack

- **Static Site Generator**: Jekyll 4.4.1
- **Styling**: Tufte CSS-inspired theme with SCSS
- **Hosting**: GitHub Pages (via GitHub Actions)
- **Local Development**: Docker-based
- **Deployment**: Automatic via GitHub Actions on push to `master`

## Running Locally

Uses Docker with `ruby:3.2` base image (multi-arch: works on both arm64 and amd64).

```bash
# Build the Docker image (first time or after Gemfile changes)
docker build -t jekyll-danyx .

# Serve with live reload
docker run --rm -p 4000:4000 -v $(pwd):/srv/jekyll jekyll-danyx

# Or use justfile (requires nushell)
just build-docker   # build image
just preview        # serve with watch
just build          # build only
just preview-quick  # serve without building image (slower, uses ruby:3.2 directly)
```

Site will be available at `http://localhost:4000`

## Project Structure

### Core Directories

| Directory | Purpose |
|-----------|---------|
| `_posts/` | Blog posts (94 posts, 2005-2023) in Markdown |
| `_drafts/` | Unpublished drafts |
| `_layouts/` | Page templates (`default.html`, `post.html`, `page.html`, `about.html`) |
| `_includes/` | Reusable HTML snippets (header, head, social icons) |
| `_sass/` | SCSS partials for styling |
| `css/` | Main SCSS entry points (`main.scss`, `tufte.scss`, `print.scss`) |
| `_plugins/` | Custom Liquid tags (Tufte-style sidenotes, margin notes, etc.) |
| `_data/` | Site data files (`social.yml`, `options.yml`) |
| `_site/` | Generated output (gitignored for builds) |

### Static Assets

| Directory | Purpose |
|-----------|---------|
| `img/` | Images used in posts |
| `files/` | Downloadable files, PDFs |
| `fonts/` | Web fonts |
| `js/` | JavaScript files |

### Legacy Content Folders

Many root-level folders are **old article permalinks** (e.g., `5D-retiming-first-results/`, `duck-a-la-antonioni/`, `retiming-methods-shootout/`). These exist to maintain URL compatibility for old posts.

## Key Configuration Files

- **`_config.yml`** - Jekyll site configuration (title, URL, plugins, excludes)
- **`Gemfile`** - Ruby dependencies
- **`Dockerfile`** - Docker setup for local development
- **`CNAME`** - Custom domain: `danielbachler.de`

## Styling System

The site uses a **Tufte CSS-inspired design** with:
- Dark theme (black background, light text)
- Futura PT as the base font
- Responsive typography scaling with viewport width
- Sidenotes and margin notes for annotations

### SCSS Structure

Main entry: `css/main.scss` → imports from `_sass/`:
- `_base.scss` - Base element styles
- `_custom.scss` - Site-specific customizations  
- `_layout.scss` - Layout rules
- `_fonts.scss` - Font definitions
- `_settings.scss` - Variables
- `_syntax-highlighting.scss` - Code highlighting

Alternative entry: `css/tufte.scss` for Tufte-specific styling

## Custom Liquid Tags (Plugins)

Located in `_plugins/`, these provide Tufte-style typography:

```liquid
{% sidenote 'id' 'Your sidenote text here' %}
{% marginnote 'id' 'Your margin note text here' %}
{% margin_figure 'id' '/path/to/image.jpg' 'Caption' %}
{% fullwidth '/path/to/image.jpg' 'Caption' %}
{% newthought 'Opening phrase' %}
{% maincolumn_img '/path/to/image.jpg' 'Caption' %}
{% mathjax %}...{% endmathjax %}
```

## Post Format

Posts use standard Jekyll front matter:

```yaml
---
layout: post
title: Your Post Title
toc: true  # Optional: enables table of contents
---
```

Posts go in `_posts/` with filename format: `YYYY-MM-DD-slug.md`

## Key Pages

- `index.html` - Blog home with pagination
- `about.html` - About page
- `cv.html` - CV/Resume page
- `feed.xml` - RSS feed

## Deployment

The site deploys automatically via **GitHub Actions** when you push to `master`:

1. Push changes to `master` branch
2. GitHub Actions builds the Jekyll site (see `.github/workflows/jekyll.yml`)
3. Built site is deployed to GitHub Pages

To check deployment status:
```bash
gh run list --limit 5
gh run view <run-id>  # for details
```

No manual build step required - just push and the site updates automatically.

## Plugins Used

- `jekyll-paginate` - Blog pagination
- `jekyll-gist` - GitHub Gist embedding
- `jekyll-feed` - RSS feed generation
- `jekyll-toc` - Table of contents generation
