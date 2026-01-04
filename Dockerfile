# Use official Ruby image (multi-arch: supports arm64 and amd64)
FROM ruby:3.2

# Install build dependencies
RUN apt-get update && apt-get install -y build-essential

# Set the working directory
WORKDIR /srv/jekyll

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Expose the port Jekyll uses
EXPOSE 4000

# Set the default command to serve the Jekyll site
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--force_polling", "--livereload"]
