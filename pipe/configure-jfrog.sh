#!/bin/bash
source "$(dirname "$0")/common.sh"

# required parameters
ARTIFACTORY_URL=${ARTIFACTORY_URL:?'ARTIFACTORY_URL variable missing.'}
ARTIFACTORY_USER=${ARTIFACTORY_USER:?'ARTIFACTORY_USER variable missing.'}
ARTIFACTORY_PASSWORD=${ARTIFACTORY_PASSWORD:?'ARTIFACTORY_PASSWORD variable missing.'}
MAVEN_SNAPSHOT_REPO=${MAVEN_SNAPSHOT_REPO:?'MAVEN_SNAPSHOT_REPO variable missing.'}
MAVEN_RELEASE_REPO=${MAVEN_RELEASE_REPO:?'MAVEN_RELEASE_REPO variable missing.'}

FOLDER=${FOLDER:="."}
JFROG_CLI_TEMP_DIR=${JFROG_CLI_TEMP_DIR:="${FOLDER}/"}
JFROG_CLI_HOME_DIR=${JFROG_CLI_HOME_DIR:="${FOLDER}/"}

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