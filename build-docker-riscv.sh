#!/bin/bash
# DO NOT UPSTREAM THIS FILE

GITHUB_REF=${GITHUB_REF:-refs/heads/master}

if [[ $GITHUB_REF == refs/tags/* ]]; then
  DOCKER_IMAGE_TAG=${GITHUB_REF#refs/tags/}
fi

if [[ $GITHUB_REF == refs/heads/* ]]; then
  DOCKER_IMAGE_TAG=${GITHUB_REF#refs/heads/}

  if [[ $DOCKER_IMAGE_TAG == master ]]; then
    DOCKER_IMAGE_TAG=latest
    AUTO_UPGRADE=1
  fi
fi

REPOS=(${REPOS:-ngc7331/acme.sh})
TAGS=()
for repo in ${REPOS[@]}; do
	TAGS+=("-t ${repo,,}:${DOCKER_IMAGE_TAG}")
    TAGS+=("-t ${repo,,}:latest")
done

DOCKER_LABELS=()
while read -r label; do
  DOCKER_LABELS+=(--label "${label}")
done <<<"${DOCKER_METADATA_OUTPUT_LABELS}"

docker buildx build \
  ${TAGS[@]} \
  --push \
  --build-arg AUTO_UPGRADE=${AUTO_UPGRADE} \
  --platform linux/riscv64 .
