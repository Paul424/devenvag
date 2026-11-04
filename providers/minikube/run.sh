#!/bin/bash
set -euxo pipefail

BASE=$(dirname $(dirname $(dirname $(realpath $0))))

# Generate a self-signed CA certificate and private key for Keycloak
bash $BASE/scripts/generate-ca.sh

# Move the crt into a fixed folder which is mounted into the control-plane container by default
mkdir -p ~/.minikube/files/var/lib/minikube/certs
cp $BASE/ca/keycloak-ca.crt ~/.minikube/files/var/lib/minikube/certs/keycloak-ca.crt

minikube start \
    --nodes=1 \
    --driver=docker \
    --container-runtime=docker \
    --image-repository=registry.devenv.local:5000/k8s \
    --insecure-registry="registry.devenv.local:5000" \
    --base-image=registry.lan:5000/k8s-minikube/kicbase:v0.0.51 \
    --cpus=4 \
    --memory=16384 \
    --cni=calico \
    --subnet=192.168.49.0/24 \
    --extra-config=apiserver.oidc-issuer-url=https://keycloak.devenv.local/realms/me-yoda \
    --extra-config=apiserver.oidc-client-id=kubernetes \
    --extra-config=apiserver.oidc-username-claim=preferred_username \
    --extra-config=apiserver.oidc-username-prefix=- \
    --extra-config=apiserver.oidc-groups-claim=groups \
    --extra-config=apiserver.oidc-ca-file=/var/lib/minikube/certs/deag-keycloak-ca.crt

minikube ip
minikube addons enable metallb
minikube addons enable csi-hostpath-driver

kubectl get nodes
