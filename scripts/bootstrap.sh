#!/bin/bash
set -euxo pipefail

BASE=$(dirname $(dirname $(realpath $0)))

###################################################
# Run a local zot registry for the bootstrap images

# Load the zot image into the docker daemon
skopeo copy dir:$BASE/artifacts/transfer/ghcr.io/project-zot/zot:v2.1.11 \
  docker-daemon:ghcr.io/project-zot/zot:v2.1.11

# Run (or restart) zot
ZOT_CONTAINERS=$(docker ps --quiet --filter ancestor=ghcr.io/project-zot/zot:v2.1.11)
if [ -n "$ZOT_CONTAINERS" ]; then
  docker rm --force $ZOT_CONTAINERS
fi
docker run --rm --detach \
    -p 5000:5000 \
    -v "$BASE/artifacts/zot-data:/var/lib/registry" \
    -v "$BASE/config/zot/zot-config.json:/etc/zot/config.json:ro" \
    -v "$BASE/ca/zot:/etc/zot/tls:ro" \
    ghcr.io/project-zot/zot:v2.1.11

until curl --fail --silent --cacert "$BASE/ca/zot/ca.crt" \
    https://registry.dev.local:5000/v2/_catalog; do
  echo "Waiting for zot registry to be ready..."
  sleep 1
done

# Push images to the local zot registry
bash $BASE/scripts/vendor.sh push

###################################################
# Bootstrap cluster
bash $BASE/providers/minikube/run.sh
