#!/bin/bash

set -eu

# If you build HEAD the pipeline.sh step, because it runs first, won't yet
# have the updated commit SHA. So we have to figure it out ourselves.
if [[ "${BUILDKITE_COMMIT:-HEAD}" == "HEAD" ]]; then
  commit=$(git show HEAD -s --pretty='%h')
else
  commit="${BUILDKITE_COMMIT}"
fi

# We have to use cat because pipeline.yml $ interpolation doesn't work in YAML
# keys, only values

cat <<YAML
steps:
  - label: run bats tests
    plugins:
      docker-compose#v1.2.1:
        run: tests

  - wait
  - label: check login happens correctly
    command: grep 032379705303 ~/.docker/config.json
    plugins:
      ${BUILDKITE_REPO}#${commit}:
        login: "true"
        account-ids: "032379705303"
YAML
