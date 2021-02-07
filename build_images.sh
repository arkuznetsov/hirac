#!/bin/bash
set -e

export $(grep -v '^#' .env | xargs)

docker build -t demoncat/onec:full-"$ONEC_VERSION" \
    --build-arg ONEC_USERNAME="$ONEC_USERNAME" \
    --build-arg ONEC_PASSWORD="$ONEC_PASSWORD"  \
    --build-arg VERSION="$ONEC_VERSION" tools/docker/onec-full


docker build -t demoncat/onec:full-osweb-test-"$ONEC_VERSION" \
    --build-arg ONEC_VERSION="$ONEC_VERSION" \
    --build-arg OSCRIPT_VERSION="$OSCRIPT_VERSION" .
