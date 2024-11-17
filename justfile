set shell := ["nu", "-c"]

preview:
  docker run -p 4000:4000 -v $"($env.PWD):/srv/jekyll" docker.io/library/jekyll-danyx -- jekyll serve --watch --force_polling

build:
  docker run -p 4000:4000 -v $"($env.PWD):/srv/jekyll" docker.io/library/jekyll-danyx jekyll build