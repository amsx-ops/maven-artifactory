#!/bin/bash
#
# artifactory-maven pipe
#
# Required globals:
#   ARTIFACTORY_URL
#   ARTIFACTORY_USER
#   ARTIFACTORY_PASSWORD
#   MAVEN_SNAPSHOT_REPO
#   MAVEN_RELEASE_REPO
#
# Optional globals:
#   FOLDER
#   EXTRA_ARGS
#   MAVEN_COMMAND
#   JFROG_CLI_TEMP_DIR
#   JFROG_CLI_HOME_DIR
#   COLLECT_ENV
#   COLLECT_GIT_INFO
#   COLLECT_BUILD_INFO
#   BUILD_NAME
#   EXTRA_BAG_ARGS
#

source "$(dirname "$0")/common.sh"

## Enable debug mode.
DEBUG_ARGS=
enable_debug() {
  if [[ "${DEBUG}" == "true" ]]; then
    info "Enabling debug mode."
    set -x
    DEBUG_ARGS="--verbose"
    export JFROG_CLI_LOG_LEVEL="DEBUG"
  fi
}

info "Starting pipe execution..."

# required parameters
ARTIFACTORY_URL=${ARTIFACTORY_URL:?'ARTIFACTORY_URL variable missing.'}
ARTIFACTORY_USER=${ARTIFACTORY_USER:?'ARTIFACTORY_USER variable missing.'}
ARTIFACTORY_PASSWORD=${ARTIFACTORY_PASSWORD:?'ARTIFACTORY_PASSWORD variable missing.'}
MAVEN_SNAPSHOT_REPO=${MAVEN_SNAPSHOT_REPO:?'MAVEN_SNAPSHOT_REPO variable missing.'}
MAVEN_RELEASE_REPO=${MAVEN_RELEASE_REPO:?'MAVEN_RELEASE_REPO variable missing.'}

# optional parameters
MAVEN_COMMAND=${MAVEN_COMMAND:="clean install"}
BUILD_NAME=${BUILD_NAME:=$BITBUCKET_REPO_OWNER-$BITBUCKET_REPO_SLUG-$BITBUCKET_BRANCH}
FOLDER=${FOLDER:="."}
JFROG_CLI_TEMP_DIR=${JFROG_CLI_TEMP_DIR:="${FOLDER}/"}
JFROG_CLI_HOME_DIR=${JFROG_CLI_HOME_DIR:="${FOLDER}/"}
COLLECT_ENV=${COLLECT_ENV:="true"}
COLLECT_GIT_INFO=${COLLECT_GIT_INFO:="true"}
COLLECT_BUILD_INFO=${COLLECT_BUILD_INFO:="true"}
EXTRA_ARGS=${EXTRA_ARGS:=""}
EXTRA_BAG_ARGS=${EXTRA_BAG_ARGS:=""}
DEBUG=${DEBUG:="false"}

# Set the environment variable
export M2_HOME=/usr/share/maven
export JFROG_CLI_TEMP_DIR=$JFROG_CLI_TEMP_DIR
export JFROG_CLI_HOME_DIR=$JFROG_CLI_HOME_DIR
export BUILD_URL="https://bitbucket.org/${BITBUCKET_REPO_OWNER}/${BITBUCKET_REPO_SLUG}/addon/pipelines/home#!/results/${BITBUCKET_BUILD_NUMBER}"

cat <<EOF >$FOLDER/configuration.yaml
version: 1
type: maven
resolver:
  snapshotRepo: ${MAVEN_SNAPSHOT_REPO}
  releaseRepo: ${MAVEN_RELEASE_REPO}
  serverID: artifactory
deployer:
  snapshotRepo: ${MAVEN_SNAPSHOT_REPO}
  releaseRepo: ${MAVEN_RELEASE_REPO}
  serverID: artifactory
EOF

debug "build name is ${BUILD_NAME}"
debug "build number is ${BITBUCKET_BUILD_NUMBER}"

check_status() {
if [[ "${status}" -eq 0 ]]; then
  success "Maven packages published successfully."
else
  fail "Failed to publish Maven packages."
fi
}

# Configure Artifactory instance with JFrog CLI
run jfrog rt config --url=$ARTIFACTORY_URL --user=$ARTIFACTORY_USER --password=$ARTIFACTORY_PASSWORD --interactive=false artifactory
check_status

# Run the MVN install command
run jfrog rt mvn "${MAVEN_COMMAND} -f ${FOLDER}/pom.xml" $FOLDER/configuration.yaml --build-name=$BUILD_NAME --build-number=$BITBUCKET_BUILD_NUMBER $EXTRA_ARGS
check_status

# Capture environment variables for build information
if [[ "${COLLECT_ENV}" == "true" ]]; then
   info "Capturing environment variables"
   run jfrog rt bce $BUILD_NAME $BITBUCKET_BUILD_NUMBER
   check_status
fi

# Collecting Information from Git
if [[ "${COLLECT_GIT_INFO}" == "true" ]]; then
   info "Collecting Information from Git"
   run jfrog rt bag $BUILD_NAME $BITBUCKET_BUILD_NUMBER $EXTRA_BAG_ARGS
   check_status
fi

# Publish build information to Artifactory
if [[ "${COLLECT_BUILD_INFO}" == "true" ]]; then
   info "Capturing build information"
   run jfrog rt bp $BUILD_NAME $BITBUCKET_BUILD_NUMBER --build-url="${BUILD_URL}"
   check_status
fi

