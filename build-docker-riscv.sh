#!/bin/bash
# DO NOT UPSTREAM THIS FILE

VERSION=$(cat ./acme.sh | grep 'VER=' | cut -d '=' -f 2 | tr -d '"')

REPOS=(${REPOS:-ngc7331/acme.sh})
TAGS=()
for repo in ${REPOS[@]}; do
  TAGS+=("-t ${repo,,}:${VERSION}")
  TAGS+=("-t ${repo,,}:latest")
done

DOCKER_LABELS=()
if [ -n "${DOCKER_METADATA_OUTPUT_LABELS}" ]; then
  while read -r label; do
    DOCKER_LABELS+=(--label "${label}")
  done <<<"${DOCKER_METADATA_OUTPUT_LABELS}"
fi

docker buildx build \
  ${TAGS[@]} \
  "${DOCKER_LABELS[@]}" \
  --push \
  --build-arg AUTO_UPGRADE=${AUTO_UPGRADE} \
  --platform linux/riscv64 .
