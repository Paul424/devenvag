#!/bin/bash
set -euxo pipefail

BASE=$(dirname $(dirname $(realpath $0)))
if [[ "${1:-}" == "pull" ]]; then
  # Have skopeo pull all the images listed in artifacts/images.yaml and store them in artifacts/transfer 
  # while keeping metadata.
  # @todo: login using PAT?
  skopeo sync --all --src yaml --dest dir $BASE/artifacts/images.yaml $BASE/artifacts/transfer

elif [[ "${1:-}" == "push" ]]; then
    # Have skopeo push all the images listed in artifacts/images.yaml from artifacts/transfer to the airgapped registry
    skopeo sync --all --src dir --dest docker $BASE/artifacts/transfer registry.dev.local:5000

    # --dest-tls-verify=false
fi
