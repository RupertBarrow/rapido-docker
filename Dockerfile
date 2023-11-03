FROM heroku/heroku:22

ENV SHELL /bin/bash
ENV DEBIAN_FRONTEND=noninteractive

ENV SF_CLI_VERSION=$SF_CLI_VERSION
ENV RAPIDO_SF_PLUGIN_VERSION=$RAPIDO_SF_PLUGIN_VERSION

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

# Install Puppeteer dependencies
# see https://stackoverflow.com/questions/64361897/puppeteer-not-working-on-vps-but-running-locally
RUN apt-get install -y libnss3-dev libatk1.0-0 libatk-bridge2.0-0 libcups2 libgbm1 libpangocairo-1.0-0 libgtk-3-0

# Install SF CLI rapido-sf-plugin
RUN echo y | sf plugins:install rapido-sf-plugin



# Installed versions
RUN set -x && \
  node -v && \
  npm -v && \
  git --version && \
  sf version && \
  sf plugins --core

ENV SFDX_CONTAINER_MODE true
ENV DEBIAN_FRONTEND=dialog
