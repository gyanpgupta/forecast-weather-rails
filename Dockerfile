# Use the official Ruby image as the base image
FROM ruby:3.1.3

# Set the working directory inside the container
WORKDIR /app

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./

# Install bundler and gems
RUN gem install bundler
RUN bundle install

# Copy the rest of the application code into the container
COPY . .

# Set environment variables if needed
ENV RAILS_ENV=development

# Install SQLite 3 and other necessary dependencies
RUN apt-get update && \
    apt-get install -y sqlite3 libsqlite3-dev

# Precompile assets and run database migrations
RUN bundle exec rails assets:precompile
RUN bundle exec rails db:migrate

# Expose port 3000 to the host machine
EXPOSE 3120

# Start the Rails server and Sidekiq
CMD ["sh", "-c", "bundle exec rails server -b 0.0.0.0 & bundle exec sidekiq"]
