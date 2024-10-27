# Use the official Jekyll Docker image as the base
FROM jekyll/jekyll:4.2.0

# Set the working directory inside the container
WORKDIR /srv/jekyll

# Copy over your Gemfile to install necessary gems
COPY Gemfile /srv/jekyll/Gemfile

# Install bundler if not already available
RUN gem install bundler:1.16.1

# Install the gems from your Gemfile
RUN bundle install

# Expose the port Jekyll uses
EXPOSE 4000

# Set the default command to serve the Jekyll site
CMD ["jekyll", "serve", "--force-polling", "--livereload"]