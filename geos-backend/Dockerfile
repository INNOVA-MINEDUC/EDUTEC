# Use Ruby 3.0 slim on Bullseye to match Gemfile and have working repositories
FROM ruby:3.0-slim-bullseye

ENV TZ America/Sao_Paulo

# Install essential Linux packages
RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends \
  build-essential \
  git \
  libpq-dev \
  nodejs \
  sudo \
  unzip \
  cron \
  ntp \
  tzdata \
  && rm -rf /var/lib/apt/lists/*

# Files created inside the container respect the ownership
RUN adduser --shell /bin/bash --disabled-password --gecos "" app \
  && adduser app sudo \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN echo 'Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bundle/bin"' > /etc/sudoers.d/secure_path
RUN chmod 0440 /etc/sudoers.d/secure_path

# Define where our application will live inside the image
ENV RAILS_ROOT /app

# Create application home.
RUN mkdir -p $RAILS_ROOT/tmp/pids

# Set our working directory inside the image
WORKDIR $RAILS_ROOT

COPY Gemfile ./
# COPY Gemfile.lock ./ # Uncomment if you have one

RUN gem install bundler --no-document
RUN bundle install --jobs $(nproc) --retry 3

RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime

COPY . .

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]