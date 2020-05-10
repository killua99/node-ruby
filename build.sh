#!/usr/bin/env bash

set -e

POSITIONAL=()

while [[ $# -gt 0 ]]; do
    key="$1"

    case "$key" in
        -h|--help)
            cat <<EOF

Comman usage:

./build.sh [<version>] [<major_version>] [<path/dockerfile>] --latest -d|--debug -h|--help

Arguments:

  🔰 version        Version number {node}-{ruby}. Ex: 10-2.5.6

Options:

  🔰 latest         Tag build latest
  🔰 d|--debug      Print run time commands
  🔰 h|--help       Print this message

Help:

  This bash script is a helper to tag new mastodon build using alpine or buster-slim as base
  full usage example:

    ``./build.sh 12-2.6.5 12-2.6 node12/ruby2.6.5 --latest``
    ``./build.sh 13.14-2.7.1-alpine3.11 13-2.7-alpine node13/alpine/ruby2.7.1 --latest``
    ``./build.sh 12-2.6.5 12-2.6 node12/ruby2.6.5 --debug``

EOF
            exit 0
            ;;
        --latest)
            LATEST="-t killua99/node-ruby:latest"
            shift
            ;;
        -d|--debug)
            set -x
            shift
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL[@]}"

TAG="${1:-latest}"
MAJOR_TAG="${2:-12-2.6}"
BUILD_LOCATION="${3:-node12/ruby2.6.5}"
LATEST=${LATEST:-""}

cat <<EOF

We're about to build docker 🚢 image for the next platforms:

    📌 linux/amd64
    📌 linux/arm64
    📌 linux/arm/v7

If you wish to build for only one platform please ask for help: ``./build.sh -h|--help``

EOF

docker buildx build \
    --push \
    --platform linux/amd64,linux/arm64,linux/arm/v7 \
    ${LATEST} \
    -t killua99/node-ruby:${MAJOR_TAG} \
    -t killua99/node-ruby:${TAG} ${BUILD_LOCATION}

if [[ ! -z ${PUSHOVER_API_KEY} ]]; then
    curl -s \
        --form-string "token=${PUSHOVER_API_KEY}" \
        --form-string "user=${PUSHOVER_USER_KEY}" \
        --form-string "message=Node Ruby docker build 🚢

Build ${TAG} complete" \
        https://api.pushover.net/1/messages.json
fi
