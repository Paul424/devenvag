#!/bin/bash
set -euxo pipefail

BASE=$(dirname $(dirname $(realpath $0)))

###################################################
# Run a local zot registry for the initial images

# Load the zot image into the docker daemon
skopeo copy dir:$BASE/artifacts/transfer/zot:v2.1.11 \
  docker-daemon:ghcr.io/project-zot/zot:v2.1.11

# Have the docker daemon trust the zot registry
bash $BASE/scripts/generate-zot-ca.sh
sudo mkdir -p /etc/docker/certs.d/registry.dev.local:5000
sudo cp $BASE/ca/zot/ca.crt /etc/docker/certs.d/registry.dev.local:5000/ca.crt

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

# Push images to the local zot registry
bash $BASE/scripts/vendor.sh push
