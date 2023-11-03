#!/usr/bin/env node

// I picked this up from https://github.com/salesforcecli/sfdx-cli/scripts/docker-publish.js and adapted it

/**
 * This should normally be run without any environment changes and will build, tag, and push 2 docker images for latest-rc
 * Should you ever need to manually run this script, then
 * 1. make sure you've logged into docker from its CLI `docker login`
 * 3. provide the version, example: SF_CLI_VERSION=2.15.9 RAPIDO_SF_PLUGIN_VERSION=1.0.24 ./scripts/docker-publish.js
 * 4. you can add NO_PUBLISH=true if you want to only do local builds from the script
 */
const shell = require("shelljs")
const fs = require("fs-extra")
const dockerShared = require("./docker-shared")

shell.set("-e")
shell.set("+v")

const DOCKER_HUB_REPOSITORY = "rupertbarrow/rapido-sf-cli"

;(async () => {
  dockerShared.validateDockerEnv()
  const DOCKER_HUB_REPOSITORY_TAG = await dockerShared.getCliVersion()
  const SF_CLI_VERSION = process.env.SF_CLI_VERSION ?? "latest"
  const RAPIDO_SF_PLUGIN_VERSION =
    process.env.RAPIDO_SF_PLUGIN_VERSION ?? "latest"

  shell.exec(
    `docker build \
      --file ./Dockerfile \
      --build-arg SF_CLI_VERSION=${SF_CLI_VERSION} \
      --build-arg RAPIDO_SF_PLUGIN_VERSION=${RAPIDO_SF_PLUGIN_VERSION} \
      --tag ${DOCKER_HUB_REPOSITORY}:${DOCKER_HUB_REPOSITORY_TAG} \
      --no-cache .`
  )

  if (process.env.NO_PUBLISH) return

  // Push to the Docker Hub Registry
  shell.exec(
    `docker push ${DOCKER_HUB_REPOSITORY}:${DOCKER_HUB_REPOSITORY_TAG}`
  )

  // This normally defaults to latest.  If you've supplied it in the environment, we're not tagging latest.
  //if (process.env['DOCKER_HUB_REPOSITORY_TAG']) return;

  // tag the newly created version as latest-rc
  shell.exec(
    `docker tag  ${DOCKER_HUB_REPOSITORY}:${DOCKER_HUB_REPOSITORY_TAG} ${DOCKER_HUB_REPOSITORY}:latest`
  )
  shell.exec(`docker push ${DOCKER_HUB_REPOSITORY}:latest`)
})()
