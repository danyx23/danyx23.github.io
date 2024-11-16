set shell := ["nu", "-c"]

preview:
  docker run -p 4000:4000 -v $"($env.PWD):/srv/jekyll" docker.io/library/jekyll-danyx

build:
  docker run -p 4000:4000 -v $"($env.PWD):/srv/jekyll" docker.io/library/jekyll-danyx jekyll build