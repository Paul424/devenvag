#!/bin/bash
set -euxo pipefail

BASE=$(dirname $(dirname $(realpath $0)))
SOPS_KEY_NAME="dev.local"


##############################################################################
# Run a local zot registry for the bootstrap images
#

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

# Push charts and images to the local zot registry
bash $BASE/scripts/vendor.sh push-to-zot

##############################################################################
# Bootstrap cluster
# 

bash $BASE/providers/minikube/run.sh

# Create the namespace for initial secrets
kubectl create namespace env --dry-run=client -o yaml | kubectl apply -f -

# Export the SOPS key to the cluster
gpg --export-secret-key --armor "${SOPS_KEY_NAME}" | kubectl create secret generic sops-gpg -n env --from-file=key.asc=/dev/stdin --dry-run=client -o yaml | kubectl apply -f -

# Deploy flux
kubectl apply -k $BASE/environments/dev01/gitops

# Wait for the controllers
kubectl wait --for=condition=available --timeout "300s" -n flux "deployment/helm-controller"
kubectl wait --for=condition=available --timeout "300s" -n flux "deployment/kustomize-controller"
kubectl wait --for=condition=available --timeout "300s" -n flux "deployment/notification-controller"
kubectl wait --for=condition=available --timeout "300s" -n flux "deployment/source-controller"

# Publish the initial cluster configuration to the zot OCI registry
SSL_CERT_FILE=$BASE/ca/zot/ca.crt flux push artifact oci://registry.dev.local:5000/platform/cluster:v1 \
  --path=./environments \
  --source="local" \
  --revision="v1"

# Make the ca available to the source (controller)
kubectl create secret generic registry-zot-ca -n env \
    --from-file=ca.crt=$BASE/ca/zot/ca.crt \
    --dry-run=client -o yaml | kubectl apply -f -

# For temp / dev only first develop against the public repo, then later replace with OCI artifact
# Git (private) repo credentials
kubectl create secret generic private-git -n env \
    --from-literal=username=$REGISTRY_UPSTREAM_USERNAME \
    --from-literal=password=$REGISTRY_UPSTREAM_PAT \
    --dry-run=client -o yaml | kubectl apply -f -

# The top level reconciler(s)
kubectl apply -k $BASE/environments/dev01/env
