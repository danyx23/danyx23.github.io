set shell := ["nu", "-c"]

preview:
  docker run -p 4000:4000 -v $"($env.PWD):/srv/jekyll" docker.io/library/jekyll-danyx -- jekyll serve --watch --force_polling

build:
  docker run -p 4000:4000 -v $"($env.PWD):/srv/jekyll" docker.io/library/jekyll-danyx jekyll build

build-docker:
  docker build -t jekyll-danyx .

[working-directory: '_site']
preview-push-site:
  git status

preview-push: preview-push-site
  git status

[working-directory: '_site']
push-site:
    git add .
    git commit
    git push

push: push-site
    git add .
    git commit
    git push
