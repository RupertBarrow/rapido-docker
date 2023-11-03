# salesforcedx-cci Docker image with SFDX CLI and Cumulus CI

Docker image with Salesforce sf CLI and rapido-sf-plugin, mainly for use in Github Actions.
This was inspired by the Salesforce DX salesforce/salesforcedx Docker files at https://github.com/salesforcecli/sfdx-cli/tree/main/dockerfiles.

## Docker hub

The docker image is published in the Docker hub at https://hub.docker.com/r/rupertbarrow/rapido-sf-docker

## Contents

- Salesforce CLI sf v2.15.19
- sf plugin RupertBarrow/rapido-sf-plugin:1.0.24

## Usage

tbc

## Dockerfile details

```
FROM heroku/heroku:22

ENV SHELL /bin/bash
ENV DEBIAN_FRONTEND=noninteractive

# Basic
RUN apt update

# Install Node
ARG node_version=v18.17.0
RUN cd /opt \
 && curl -LO https://nodejs.org/dist/${node_version}/node-${node_version}-linux-x64.tar.xz \
 && tar xJf node-${node_version}-linux-x64.tar.xz \
 && rm node-${node_version}-linux-x64.tar.xz
ENV PATH=/opt/node-${node_version}-linux-x64/bin:${PATH}

RUN npm install -g yarn --force
RUN yarn -v


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
```

## Note on versioning

I'm careful about avoiding tooling regression, so there are no implicit versions mentioned here. All version numbers are hardcoded so that tooling behaves in a reproduceable manner.

## Extending this Docker image to add your own SFDX plugins

People might want to have this same Docker file with other plugins.
This is how to proceed :

Create your own Docxker file based on this image, and add your plugins, update SFDX CLI or Cumulus CI :

```
# My new Docker file
FROM rupertbarrow/rapido-sf-docker:latest

ENV SHELL /bin/bash
ENV DEBIAN_FRONTEND=noninteractive

# Update SF CLI to the latest version
RUN sf update

# Add SF plugins here
RUN echo y | sf plugins:install sfdmu

ENV SFDX_CONTAINER_MODE true
ENV DEBIAN_FRONTEND=dialog
```

Then you can publish and use this Docker image yourself.
