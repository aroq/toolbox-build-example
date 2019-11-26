#!/usr/bin/env bash

# Idea of the install implementation is taken from https://github.com/cloudposse/build-harness/

export TOOLBOX_DOCKER_SSH_FORWARD=${1:-false}

export TOOLBOX_ORG=${1:-aroq}
export TOOLBOX_PROJECT=${2:-toolbox}
export TOOLBOX_BRANCH=${3:-master}
export TOOLBOX_DIR=${4:-.toolbox}
export TOOLBOX_CORE_DIR="${TOOLBOX_DIR}/core"

export GITHUB_REPO="https://github.com/${TOOLBOX_ORG}/${TOOLBOX_PROJECT}.git"

if [ "$TOOLBOX_PROJECT" ] && [ -d "$TOOLBOX_CORE_DIR" ]; then
  echo "Removing existing $TOOLBOX_CORE_DIR"
  rm -rf "$TOOLBOX_CORE_DIR"
fi

mkdir -p "${TOOLBOX_DIR}"

CLONE_CMD="git clone --quiet -b ${TOOLBOX_BRANCH} ${GITHUB_REPO} ${TOOLBOX_CORE_DIR} &> /dev/null"
echo "Executing: ${CLONE_CMD}"
eval "${CLONE_CMD}"

(
cd "${TOOLBOX_CORE_DIR}" || exit
git rev-parse --short HEAD > REVISION
rm -fR .git
)


