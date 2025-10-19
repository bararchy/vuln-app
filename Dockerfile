# Use Ruby 3.3 as base image (compatible with Rails 8)
FROM ruby:3.3-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    libsqlite3-dev \
    libyaml-dev \
    nodejs \
    npm \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application
COPY . .

# Create necessary directories
RUN mkdir -p tmp/pids tmp/cache tmp/sockets log db

# Precompile assets (if needed)
RUN bundle exec rake assets:precompile RAILS_ENV=production || true

# Setup database
RUN bundle exec rake db:create RAILS_ENV=development || true
RUN bundle exec rake db:migrate RAILS_ENV=development || true

# Expose port 3000
EXPOSE 3000

# Set environment to development by default
ENV RAILS_ENV=development
ENV RACK_ENV=development

# Start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
