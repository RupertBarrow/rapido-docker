FROM heroku/heroku:22

ENV SHELL /bin/bash
ENV DEBIAN_FRONTEND=noninteractive

# Basic
RUN apt update
RUN echo y | apt install software-properties-common

# Get Git >= 2.18 : actions/checkout@v2 says "To create a local Git repository instead, add Git 2.18 or higher to the PATH"
RUN add-apt-repository -y ppa:git-core/ppa
RUN apt-get update
RUN apt-get install -y --no-install-recommends git \
  && rm -rf /var/lib/apt/lists/*

# Install SF CLI
RUN npm install -g @salesforce/cli

# Install SF CLI rapido-sf-plugin
RUN echo y | sf plugins:install rapido-sf-plugin@1.0.24

# Install Puppeteer dependencies
# see https://stackoverflow.com/questions/64361897/puppeteer-not-working-on-vps-but-running-locally
RUN apt-get install libnss3-dev libatk1.0-0 libatk-bridge2.0-0 libcups2 libgbm1 libpangocairo-1.0-0 libgtk-3-0


# Installed versions
RUN set -x && \
  node -v && \
  npm -v && \
  git --version && \
  sf version && \
  sf plugins --core

ENV SFDX_CONTAINER_MODE true
ENV DEBIAN_FRONTEND=dialog
