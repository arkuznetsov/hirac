#!/bin/bash
set -e

export $(grep -v '^#' .env | xargs)

HIRAC_NAME_IMAGE="${1:-oscript/hirac:latest}"

if [ ! -d "tools/docker/onec-full"]; then
    git submodule update --init --recursive
fi

docker build -t demoncat/onec:full-"$ONEC_VERSION" \
    --build-arg ONEC_USERNAME="$ONEC_USERNAME" \
    --build-arg ONEC_PASSWORD="$ONEC_PASSWORD"  \
    --build-arg VERSION="$ONEC_VERSION" tools/docker/onec-full


docker build -t "$HIRAC_NAME_IMAGE" \
    --build-arg ONEC_VERSION="$ONEC_VERSION" \
    --build-arg OSCRIPT_VERSION="$OSCRIPT_VERSION" .
