#FROM node:lts-alpine

#add usefull tools
# see https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md
#RUN apk add --update --no-cache  \
#      git \
#      findutils \
#      bash \
#      unzip \
#      curl \
#      wget \
#      npm

#RUN apk add --update --no-cache  \
#      openssh-client \
#      chromium \
#      nss \
#      freetype \
#      harfbuzz \
#      ca-certificates \
#      ttf-freefont \
#      nodejs \
#      yarn

# Install Chromimum and Puppeteer 
# see https://github.com/puppeteer/puppeteer/issues/7740#issuecomment-1081225615
# see https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#running-puppeteer-in-docker
# this Chromium version for Puppeteer v21.5.0 used by rapido-sf-plugin : see https://github.com/puppeteer/puppeteer/blob/main/packages/puppeteer-core/src/revisions.ts
#RUN apk add --no-cache \
#    msttcorefonts-installer font-noto fontconfig \
#    freetype ttf-dejavu ttf-droid ttf-freefont ttf-liberation \
#    chromium=119.0.6045.105 \
#  && rm -rf /var/cache/apk/* /tmp/*

#RUN update-ms-fonts \
#    && fc-cache -f

#ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
#ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium-browser

#WORKDIR /app


#FROM node:lts-alpine


# Install Chromimum : see https://www.koyeb.com/tutorials/deploy-a-web-scraper-using-puppeteer-node-and-docker
#WORKDIR /app

#RUN apk update && apk add --no-cache nmap && \
#    echo @edge https://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
#    echo @edge https://dl-cdn.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
#    apk update && \
#    apk add --no-cache \
#      chromium \
#      harfbuzz \
#      "freetype>2.8" \
#      ttf-freefont \
#      nss

#ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
#ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

#COPY . /app

FROM node:lts-alpine

RUN apk add --update --no-cache  \
      git \
      findutils \
      bash \
      unzip \
      curl \
      wget

  # install Salesforce CLI from npm
RUN npm install @salesforce/cli --global

# Add user so we don't need --no-sandbox.
RUN addgroup -S pptruser && adduser -S -G pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads /app    \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app
    #&& chmod a+r -R /root \
    #&& chmod a+w -R /root/.sf


# see https://stackoverflow.com/questions/57534295/npm-err-tracker-idealtree-already-exists-while-creating-the-docker-image-for
WORKDIR /home/pptruser
#COPY ./ ./

# Puppeteer version used in rapido-sf-plugin
#RUN npm init -y &&  \
#    npm install puppeteer@21.5.0 
RUN npm install puppeteer@21.5.0 puppeteer-core@21.5.0


# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
#ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
# Puppeteer v13.5.0 works with Chromium 100.
#RUN npm install puppeteer@21.5.0 --global

# install Rapido plugin
RUN echo y | sf plugins:install rapido-sf-plugin


RUN echo "############ DEBUG as ROOT ###############" && \
    set -x && \
    env && \
    pwd && ls -al && ls -al /root && \
    which bash
    #sf --version && \
    #sf plugins

RUN sf rapido:scrape:changeset:list -h
#RUN ls -al /root/.local/share/sf


# Run everything after as non-privileged user (avoids changing HOME=root and using --no-sandbox in Puppeteer)
USER pptruser

#RUN sf --version && which sf
#RUN ls -al /home/pptruser /root

# Installed versions
RUN echo "############ DEBUG as PPTRUSER ###############" && \
    set -x && \
    node -v && \
    npm -v
    #sf --version && \
    #sf plugins && \
    #HOME=/root sf rapido:scrape:changeset:list -h


USER root

# Chrome installed
RUN ls -al / \
    && ls -al /root \
    && ls -al /root/.cache/ \
    && ls -al /root/.cache/puppeteer/ \
    && ls -al /root/.cache/puppeteer/chrome \
    && ls -al /root/.cache/puppeteer/chrome/linux-119.0.6045.105 \
    && ls -al /root/.cache/puppeteer/chrome/linux-119.0.6045.105/chrome-linux64 \
    && ls -al /root/.cache/puppeteer/chrome/linux-119.0.6045.105/chrome-linux64/chrome

ENV SFDX_CONTAINER_MODE true
ENV SF_CONTAINER_MODE true
ENV DEBIAN_FRONTEND=dialog
ENV SHELL /bin/bash