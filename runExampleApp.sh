#!/bin/bash

set -e

PREREQUISITES=("yarn" "node")
SCRIPT_DIR=$(
  cd "$(dirname "$0")"
  pwd
)
USE_FORMAT=$(
  type tput >/dev/null 2>&1
  if [ $? -eq 0 ]; then echo "true"; else echo "false"; fi
)

function boldMessage() {
  if [ "$USE_FORMAT" == "true" ]; then
    echo "$(tput bold)$1$(tput sgr 0)"
  else
    echo "$1"
  fi
}

function colorMessage() {
  if [ "$USE_FORMAT" == "true" ]; then
    echo "$(tput setaf $2)$1$(tput sgr 0)"
  else
    echo "$1"
  fi
}

function paddedMessage() {
  echo
  echo
  boldMessage "$1"
}

function checkForDependencies() {
  boldMessage "Checking for prerequisites..."
  missing=0
  for i in "${PREREQUISITES[@]}"; do
    echo -n "  $i: "

    set +e
    type $i >/dev/null 2>&1
    exists=$?
    set -e

    if [ $exists -eq 0 ]; then
      colorMessage "Y" 2
    else
      colorMessage "N" 1
    fi

    if [ $exists -ne 0 ]; then
      ((missing += 1))
    fi
  done

  if [[ $missing -gt 0 ]]; then
    echo
    echo "Not all prerequistes are installed." >&2
    exit 1
  fi
}

function updateEnvFile() {

DISCOVERY_AUTH_TYPE=iam
DISCOVERY_URL=${discovery_api_url}
DISCOVERY_APIKEY=${discovery_api_key}
  
REACT_APP_PROJECT_ID=${discovery_projectId}

export DISCOVERY_AUTH_TYPE=iam
export DISCOVERY_URL=${discovery_api_url}
export DISCOVERY_APIKEY=${discovery_api_key}
export REACT_APP_PROJECT_ID=${discovery_projectId}

}

if [ "$USE_FORMAT" == "true" ]; then tput clear; fi

#
# check for missing prerequistes
#
checkForDependencies

updateEnvFile

#
# run server setup script
#
paddedMessage "Setting up server..."
yarn workspace discovery-search-app run server:setup
colorMessage "done" 2

#
# build discovery-react-components
#
paddedMessage "Building components..."
yarn run build:pkgs 2>/tmp/component_build
if [ $? -ne 0 ]; then
  echo
  cat /tmp/component_build
  echo
  echo
  echo "Build failed with the above errors" >&2
  exit 1
fi
colorMessage "done" 2


yarn workspace discovery-search-app run start



