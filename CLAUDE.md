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

### Option 1: VS Code Dev Container (Recommended)

Open the project in VS Code and use "Reopen in Container" (requires Docker and the Dev Containers extension). The container includes Ruby, Node.js, and `pi` (pi-coding-agent).

```bash
# Inside the dev container (using just commands)
just install        # Install Ruby dependencies (runs automatically on container creation)
just preview        # Serve with live reload
just build          # Build the site
just preview-drafts # Serve including draft posts
just clean          # Clean generated files
just new-draft name # Create a new draft post
```

### Option 2: Docker without Dev Container

Uses Docker with `ruby:3.2` base image (multi-arch: works on both arm64 and amd64).

```bash
# Build the Docker image (first time or after Gemfile changes)
docker build -t jekyll-danyx .

# Serve with live reload
docker run --rm -p 4000:4000 -v $(pwd):/srv/jekyll jekyll-danyx

# Or use justfile - run OUTSIDE container
just build-docker      # build image
just preview-docker    # serve with watch via Docker
just build-docker-site # build only via Docker
just preview-quick     # serve without building image (slower, uses ruby:3.2 directly)
```

Site will be available at `http://localhost:4000`

## Dev-Browser on Host (Mac) + Container Automation

Use this when you want the automation to run inside the dev container while Chrome runs on the host Mac.

### Host (MacOS)

1. Start dev-browser on the host:

```bash
cd ~/.pi/agent/skills-repos/dev-browser/skills/dev-browser
./server.sh
```

2. Ensure Chrome is allowed to accept remote DevTools connections:

Edit `~/.pi/agent/skills-repos/dev-browser/skills/dev-browser/src/index.ts` and add the flag:

```typescript
args: [
  `--remote-debugging-port=${cdpPort}`,
  `--remote-allow-origins=*`,
],
```

Restart `./server.sh` after changing it.

### Container

1. Start the Jekyll preview server:

```bash
bundle exec jekyll serve --host 0.0.0.0
```

2. Connect to the host dev-browser API by IP (resolved from `host.docker.internal`):

```bash
getent ahostsv4 host.docker.internal | awk '{print $1}' | head -1
```

Use that IP in dev-browser client scripts, for example:

```typescript
const client = await connect("http://<HOST_IP>:9222");
const page = await client.page("jekyll");
await page.goto("http://localhost:4000");
```

Notes:
- `client.page("jekyll")` will hang if Chrome's DevTools WS is blocked or the host IP is wrong.
- If `page.goto("http://localhost:4000")` times out, make sure the preview server is running and port 4000 is reachable from the host.

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
