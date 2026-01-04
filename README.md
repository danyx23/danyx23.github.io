To run locally inside docker:

```
docker build -t jekyll-danyx .
docker run -p 4000:4000 -v .:/srv/jekyll docker.io/library/jekyll-danyx
```