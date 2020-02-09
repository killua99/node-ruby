#!/usr/bin/env bash

set -e

POSITIONAL=()

while [[ $# -gt 0 ]]; do
    key="$1"

    case "$key" in
        -h|--help)
            cat <<EOF

Comman usage:

./build.sh [<version>] --latest -d|--debug -h|--help

Arguments:

  🔰 version        Version number {node}-{ruby}. Ex: 10-2.5.6

Options:

  🔰 latest         Tag build latest
  🔰 d|--debug      Print run time commands
  🔰 h|--help       Print this message

Help:

  This bash script is a helper to tag new mastodon build using alpine as base
  full usage example:

    ``./build.sh "10-2.6.5" --latest``

    ``./build.sh "10-2.6.5" --debug``

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

MASTODON_VERSION="v${1:-2.9.3}"
TAG="${1:-latest}"
LATEST=${LATEST:-""}

cat <<EOF

We're about to build docker 🚢 image for the next platforms:

    📌 linux/amd64
    📌 linux/arm64
    📌 linux/arm/v7

If you wish to build for only one platform please ask for help: ``./build.sh -h|--help``

EOF

time docker buildx build \
    --push \
    --platform linux/amd64,linux/arm64,linux/arm/v7 \
    ${LATEST} \
    -t killua99/node-ruby:${TAG} .
