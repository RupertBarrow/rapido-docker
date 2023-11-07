FROM zenika/alpine-chrome:with-node

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD 1
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium-browser

############################################
USER root

# Install basics
RUN apk add --no-cache \
  bash \
  git \
  && rm -rf /var/cache/apk/*

# Install Salesforce CLI
RUN npm install @salesforce/cli --global

############################################
USER chrome
WORKDIR /usr/src/app

# Install Rapido SF Plugin
RUN echo y | sf plugins:install rapido-sf-plugin
COPY --chown=chrome . ./

# Installed versions
RUN set -x && \
  node -v && \
  npm -v && \
  git --version && \
  sf version && \
  sf plugins && \
  sf rapido:scrape:changeset:list -h && \
  which bash

ENV SF_CONTAINER_MODE true
ENV SFDX_CONTAINER_MODE true
